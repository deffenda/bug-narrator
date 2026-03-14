import Foundation

enum BugNarratorLinks {
    static let repository = URL(string: "https://github.com/abdenterprises/bugnarrator")!
    static let documentation = URL(string: "https://github.com/abdenterprises/bugnarrator/blob/main/docs/UserGuide.md")!
    static let issues = URL(string: "https://github.com/abdenterprises/bugnarrator/issues/new")!
    static let releases = URL(string: "https://github.com/abdenterprises/bugnarrator/releases")!
    static let supportDevelopment = URL(string: "https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8")!

    static func supportDonation(amount: Int) -> URL {
        var components = URLComponents(url: supportDevelopment, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []

        queryItems.removeAll { item in
            item.name == "amount" || item.name == "currency_code"
        }
        queryItems.append(URLQueryItem(name: "amount", value: String(amount)))
        queryItems.append(URLQueryItem(name: "currency_code", value: "USD"))

        components?.queryItems = queryItems
        return components?.url ?? supportDevelopment
    }
}
