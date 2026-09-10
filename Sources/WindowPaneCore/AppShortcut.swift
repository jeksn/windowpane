import Foundation

public struct AppShortcut: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var bundleIdentifier: String?
    public var bundleURL: URL?

    public init(
        id: UUID = UUID(),
        name: String = "",
        bundleIdentifier: String? = nil,
        bundleURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.bundleURL = bundleURL
    }

    public var isValid: Bool {
        (bundleIdentifier != nil && !bundleIdentifier!.isEmpty)
            || (bundleURL != nil)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case bundleIdentifier
        case bundleURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        bundleURL = try container.decodeIfPresent(URL.self, forKey: .bundleURL)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encodeIfPresent(bundleURL, forKey: .bundleURL)
    }
}
