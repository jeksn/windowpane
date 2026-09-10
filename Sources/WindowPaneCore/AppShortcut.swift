import Foundation

public struct AppShortcut: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var isURL: Bool
    public var bundleIdentifier: String?
    public var bundleURL: URL?
    public var urlString: String?

    public init(
        id: UUID = UUID(),
        name: String = "",
        isURL: Bool = false,
        bundleIdentifier: String? = nil,
        bundleURL: URL? = nil,
        urlString: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isURL = isURL
        self.bundleIdentifier = bundleIdentifier
        self.bundleURL = bundleURL
        self.urlString = urlString
    }

    public var url: URL? {
        urlString.flatMap { URL(string: $0) }
    }

    public var isValid: Bool {
        if isURL {
            guard let string = urlString, !string.isEmpty, URL(string: string) != nil else { return false }
            return true
        }
        return (bundleIdentifier != nil && !bundleIdentifier!.isEmpty)
            || (bundleURL != nil)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isURL
        case bundleIdentifier
        case bundleURL
        case urlString
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        isURL = try container.decodeIfPresent(Bool.self, forKey: .isURL) ?? false
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        bundleURL = try container.decodeIfPresent(URL.self, forKey: .bundleURL)
        urlString = try container.decodeIfPresent(String.self, forKey: .urlString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isURL, forKey: .isURL)
        try container.encodeIfPresent(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encodeIfPresent(bundleURL, forKey: .bundleURL)
        try container.encodeIfPresent(urlString, forKey: .urlString)
    }
}
