#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ROOT="$(cd "$ROOT" && pwd)"
cd "$ROOT"

RUN_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
RUN_STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
RUN_DATE="$(date -u +"%Y-%m-%d")"
RUN_ID="${RUN_ONCE_RUN_ID:-run-${RUN_STAMP}}"
RUN_DIR="$ROOT/runs/$RUN_DATE/$RUN_STAMP"
LOCK_DIR="$ROOT/runs/.run-once.lock"
LOCK_PID_FILE="$LOCK_DIR/pid"
BOOTSTRAP_LOG="$RUN_DIR/bootstrap.log"
REFRESH_LOG="$RUN_DIR/refresh-context.log"
AGENT_LOG="$RUN_DIR/agent.log"
VALIDATE_LOG="$RUN_DIR/validate.log"
ARTIFACT_LOG="$RUN_DIR/collect-artifacts.log"
SUMMARY_LOG="$RUN_DIR/run-once.log"

AGENT_NAME="${RUN_ONCE_AGENT_NAME:-codex}"
AGENT_MODEL="${RUN_ONCE_MODEL:-}"
CURRENT_TASK_ID="${RUN_ONCE_TASK_ID:-}"
PROMPT_FILE="${RUN_ONCE_PROMPT_FILE:-$ROOT/prompts/lean.md}"
TIMEOUT_SECONDS="${RUN_ONCE_TIMEOUT_SECONDS:-1800}"
LOCK_EXIT_CODE="${RUN_ONCE_LOCK_EXIT_CODE:-75}"

mkdir -p "$RUN_DIR"

log() {
  local message="$1"
  printf '[%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$message" | tee -a "$SUMMARY_LOG"
}

release_lock() {
  if [[ -d "$LOCK_DIR" ]] && [[ -f "$LOCK_PID_FILE" ]]; then
    local owner_pid
    owner_pid="$(tr -d '[:space:]' < "$LOCK_PID_FILE" 2>/dev/null || true)"
    if [[ "$owner_pid" == "$$" ]]; then
      rm -rf "$LOCK_DIR"
    fi
  fi
}

acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$LOCK_PID_FILE"
    printf '%s\n' "$RUN_ID" > "$LOCK_DIR/run_id"
    return 0
  fi

  local existing_pid=""
  if [[ -f "$LOCK_PID_FILE" ]]; then
    existing_pid="$(tr -d '[:space:]' < "$LOCK_PID_FILE" 2>/dev/null || true)"
  fi

  if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
    log "run-once skipped: another process already holds the lock (pid=$existing_pid)"
    return "$LOCK_EXIT_CODE"
  fi

  rm -rf "$LOCK_DIR"
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$LOCK_PID_FILE"
    printf '%s\n' "$RUN_ID" > "$LOCK_DIR/run_id"
    return 0
  fi

  log "run-once failed: could not acquire lock"
  return "$LOCK_EXIT_CODE"
}

trap release_lock EXIT INT TERM

update_session_state() {
  local status="$1"
  local note="${2:-}"
  ROOT="$ROOT"   RUN_ID="$RUN_ID"   RUN_STARTED_AT="$RUN_STARTED_AT"   AGENT_NAME="$AGENT_NAME"   AGENT_MODEL="$AGENT_MODEL"   CURRENT_TASK_ID="$CURRENT_TASK_ID"   STATUS_VALUE="$status"   NOTE_VALUE="$note"   python3 <<'PY'
import json
import os
import pathlib
from datetime import datetime, timezone

root = pathlib.Path(os.environ["ROOT"])
session_path = root / "state" / "session.json"
session = json.loads(session_path.read_text())

session["run_id"] = os.environ["RUN_ID"]
session["started_at"] = os.environ["RUN_STARTED_AT"]
session["updated_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
session["active_agent"] = os.environ["AGENT_NAME"] or session.get("active_agent")
if os.environ["AGENT_MODEL"]:
    session["active_model"] = os.environ["AGENT_MODEL"]
else:
    session.setdefault("active_model", None)
if os.environ["CURRENT_TASK_ID"]:
    session["current_task_id"] = os.environ["CURRENT_TASK_ID"]
else:
    session.setdefault("current_task_id", None)
session["status"] = os.environ["STATUS_VALUE"]
session.setdefault("notes", [])
note = os.environ["NOTE_VALUE"]
if note:
    notes = session.get("notes")
    if isinstance(notes, list):
        notes.append({
            "timestamp": session["updated_at"],
            "message": note
        })

session_path.write_text(json.dumps(session, indent=2) + "\n")
PY
}

run_with_timeout() {
  local timeout_seconds="$1"
  local log_path="$2"
  local command_string="$3"
  local timeout_marker="$RUN_DIR/.timeout-$$.marker"
  mkdir -p "$(dirname "$log_path")"
  : > "$log_path"
  printf '$ %s\n' "$command_string" >> "$log_path"
  rm -f "$timeout_marker"

  (
    cd "$ROOT"
    bash -lc "$command_string" >> "$log_path" 2>&1
  ) &
  local command_pid=$!

  (
    sleep "$timeout_seconds"
    if kill -0 "$command_pid" 2>/dev/null; then
      printf 'timed out after %s seconds\n' "$timeout_seconds" > "$timeout_marker"
      kill -TERM "$command_pid" 2>/dev/null || true
      sleep 5
      kill -KILL "$command_pid" 2>/dev/null || true
    fi
  ) &
  local watchdog_pid=$!

  local exit_code=0
  if ! wait "$command_pid"; then
    exit_code=$?
  fi

  kill "$watchdog_pid" 2>/dev/null || true
  wait "$watchdog_pid" 2>/dev/null || true

  if [[ -f "$timeout_marker" ]]; then
    printf '\n[run-once] %s\n' "$(cat "$timeout_marker")" >> "$log_path"
    rm -f "$timeout_marker"
    return 124
  fi

  return "$exit_code"
}

ensure_safe_repo_state() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "run-once aborted: repository context is not available"
    return 2
  fi

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ "$branch" == "HEAD" || -z "$branch" ]]; then
    log "run-once aborted: detached HEAD is not allowed"
    return 2
  fi

  if [[ -n "$(git diff --name-only --diff-filter=U 2>/dev/null)" ]]; then
    log "run-once aborted: unresolved merge conflicts are present"
    return 2
  fi

  if [[ -f .git/MERGE_HEAD || -d .git/rebase-merge || -d .git/rebase-apply || -f .git/CHERRY_PICK_HEAD ]]; then
    log "run-once aborted: a git merge, rebase, or cherry-pick is already in progress"
    return 2
  fi
}

run_hook_if_present() {
  local script_path="$1"
  local timeout_seconds="$2"
  local log_path="$3"
  local label="$4"
  local command_string=""

  if [[ ! -x "$script_path" ]]; then
    log "run-once skipped: $label is not present at $script_path"
    return 0
  fi

  log "run-once starting: $label"
  command_string="$(printf '%q %q' "$script_path" "$ROOT")"
  if run_with_timeout "$timeout_seconds" "$log_path" "$command_string"; then
    log "run-once finished: $label"
    return 0
  else
    local exit_code=$?
    log "run-once failed: $label exited with status $exit_code"
    return "$exit_code"
  fi
}

run_required_hook() {
  local script_path="$1"
  local timeout_seconds="$2"
  local log_path="$3"
  local label="$4"

  if [[ ! -x "$script_path" ]]; then
    log "run-once aborted: required $label hook is missing at $script_path"
    return 2
  fi

  run_hook_if_present "$script_path" "$timeout_seconds" "$log_path" "$label"
}

run_agent() {
  local agent_command="${RUN_ONCE_AGENT_CMD:-}"

  if [[ -z "$agent_command" ]]; then
    if ! command -v codex >/dev/null 2>&1; then
      log "run-once aborted: codex is not installed and RUN_ONCE_AGENT_CMD was not provided"
      return 127
    fi
    if [[ ! -f "$PROMPT_FILE" ]]; then
      log "run-once aborted: prompt file is missing at $PROMPT_FILE"
      return 2
    fi
    agent_command="$(printf 'codex run %q' "$PROMPT_FILE")"
  fi

  log "run-once starting: agent"
  if run_with_timeout "$TIMEOUT_SECONDS" "$AGENT_LOG" "$agent_command"; then
    log "run-once finished: agent"
    return 0
  else
    local exit_code=$?
    log "run-once failed: agent exited with status $exit_code"
    return "$exit_code"
  fi
}

if ! acquire_lock; then
  exit $?
fi

log "run-once started in $ROOT"

if ! run_required_hook "$ROOT/bootstrap.sh" 300 "$BOOTSTRAP_LOG" "bootstrap"; then
  update_session_state "bootstrap_failed" "bootstrap failed; see $BOOTSTRAP_LOG"
  exit $?
fi

if ! ensure_safe_repo_state; then
  update_session_state "blocked" "unsafe repository state blocked run-once; see $SUMMARY_LOG"
  exit $?
fi

if ! run_hook_if_present "$ROOT/scripts/refresh-context.sh" 120 "$REFRESH_LOG" "refresh-context"; then
  update_session_state "refresh_failed" "refresh-context failed; see $REFRESH_LOG"
  exit $?
fi

update_session_state "running" "run-once started; logs under $RUN_DIR"

if ! run_agent; then
  update_session_state "agent_failed" "agent failed; see $AGENT_LOG"
  exit $?
fi

validate_exit_code=0
if ! run_hook_if_present "$ROOT/scripts/validate.sh" 900 "$VALIDATE_LOG" "validate"; then
  validate_exit_code=$?
fi

collect_exit_code=0
if ! run_hook_if_present "$ROOT/scripts/collect-artifacts.sh" 300 "$ARTIFACT_LOG" "collect-artifacts"; then
  collect_exit_code=$?
fi

if [[ "$validate_exit_code" -ne 0 ]]; then
  update_session_state "validation_failed" "validation failed; see $VALIDATE_LOG"
  exit "$validate_exit_code"
fi

if [[ "$collect_exit_code" -ne 0 ]]; then
  update_session_state "artifact_collection_failed" "artifact collection failed; see $ARTIFACT_LOG"
  exit "$collect_exit_code"
fi

update_session_state "completed" "run-once completed successfully; logs under $RUN_DIR"
log "run-once completed successfully"
