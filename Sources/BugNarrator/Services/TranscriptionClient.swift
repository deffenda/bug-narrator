import Foundation

struct TranscriptionRequest: Sendable {
    let model: String
    let languageHint: String?
    let prompt: String?
}

struct TranscriptionResult: Sendable {
    let text: String
    let segments: [TranscriptionSegment]
}

struct TranscriptionSegment: Decodable, Sendable {
    let start: Double
    let end: Double
    let text: String
}

actor TranscriptionClient: TranscriptionServing {
    private let endpoint = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
    private let validationEndpoint = URL(string: "https://api.openai.com/v1/models")!
    private let session: URLSession
    private let fileManager: FileManager

    init(session: URLSession? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 180
            configuration.timeoutIntervalForResource = 300
            self.session = URLSession(configuration: configuration)
        }
    }

    func transcribe(fileURL: URL, apiKey: String, request: TranscriptionRequest) async throws -> TranscriptionResult {
        let urlRequest = try makeURLRequest(fileURL: fileURL, apiKey: apiKey, request: request)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            let httpResponse = response as? HTTPURLResponse

            guard let httpResponse else {
                throw AppError.transcriptionFailure("The server response was invalid.")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIErrorMapper.mapResponse(
                    statusCode: httpResponse.statusCode,
                    data: data,
                    fallback: AppError.transcriptionFailure
                )
            }

            let result = try JSONDecoder().decode(VerboseTranscriptionResponse.self, from: data)
            let transcript = result.text.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !transcript.isEmpty else {
                throw AppError.emptyTranscript
            }

            return TranscriptionResult(text: transcript, segments: result.segments ?? [])
        } catch {
            throw OpenAIErrorMapper.mapTransportError(error, fallback: AppError.transcriptionFailure)
        }
    }

    func validateAPIKey(_ apiKey: String) async throws {
        let request = makeValidationRequest(apiKey: apiKey)

        do {
            let (data, response) = try await session.data(for: request)
            let httpResponse = response as? HTTPURLResponse

            guard let httpResponse else {
                throw AppError.transcriptionFailure("The server response was invalid.")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIErrorMapper.mapResponse(
                    statusCode: httpResponse.statusCode,
                    data: data,
                    fallback: AppError.transcriptionFailure
                )
            }
        } catch {
            throw OpenAIErrorMapper.mapTransportError(error, fallback: AppError.transcriptionFailure)
        }
    }

    func makeValidationRequest(apiKey: String) -> URLRequest {
        var request = URLRequest(url: validationEndpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    func makeURLRequest(fileURL: URL, apiKey: String, request: TranscriptionRequest) throws -> URLRequest {
        try validateAudioFile(at: fileURL)

        let boundary = "Boundary-\(UUID().uuidString)"
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try makeBody(fileURL: fileURL, request: request, boundary: boundary)

        return urlRequest
    }

    func makeBody(fileURL: URL, request: TranscriptionRequest, boundary: String) throws -> Data {
        let fileData = try Data(contentsOf: fileURL)
        var body = Data()

        appendField(named: "model", value: request.model, boundary: boundary, to: &body)
        appendField(named: "response_format", value: "verbose_json", boundary: boundary, to: &body)
        appendField(named: "temperature", value: "0", boundary: boundary, to: &body)

        if let languageHint = request.languageHint, !languageHint.isEmpty {
            appendField(named: "language", value: languageHint, boundary: boundary, to: &body)
        }

        if let prompt = request.prompt, !prompt.isEmpty {
            appendField(named: "prompt", value: prompt, boundary: boundary, to: &body)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: \(mimeType(for: fileURL))\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }

    private func validateAudioFile(at fileURL: URL) throws {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw AppError.transcriptionFailure("The recorded audio file could not be found.")
        }

        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        let fileSize = (attributes[.size] as? NSNumber)?.intValue ?? 0

        guard fileSize > 0 else {
            throw AppError.transcriptionFailure("The recorded audio file was empty.")
        }
    }

    private func appendField(named name: String, value: String, boundary: String, to body: inout Data) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(value)\r\n".data(using: .utf8)!)
    }

    private func mimeType(for fileURL: URL) -> String {
        switch fileURL.pathExtension.lowercased() {
        case "m4a":
            return "audio/m4a"
        case "wav":
            return "audio/wav"
        case "mp3":
            return "audio/mpeg"
        default:
            return "application/octet-stream"
        }
    }
}

private struct VerboseTranscriptionResponse: Decodable {
    let text: String
    let segments: [TranscriptionSegment]?
}
