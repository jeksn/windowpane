import Foundation

public enum WindowDimension: Hashable, Codable {
    case percent(Double)
    case points(Double)

    private enum CodingKeys: String, CodingKey {
        case percent
        case points
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(Double.self, forKey: .percent) {
            self = .percent(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .points) {
            self = .points(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected a percent or points value"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .percent(let value): try container.encode(value, forKey: .percent)
        case .points(let value): try container.encode(value, forKey: .points)
        }
    }

    public var value: Double {
        switch self {
        case .percent(let value): return value
        case .points(let value): return value
        }
    }
}

public enum Anchor: String, Codable, CaseIterable, Hashable {
    case topLeft
    case topCenter
    case topRight
    case middleLeft
    case center
    case middleRight
    case bottomLeft
    case bottomCenter
    case bottomRight

    public enum Horizontal {
        case left
        case center
        case right
    }

    public enum Vertical {
        case top
        case center
        case bottom
    }

    public var horizontal: Horizontal {
        switch self {
        case .topLeft, .middleLeft, .bottomLeft: return .left
        case .topCenter, .center, .bottomCenter: return .center
        case .topRight, .middleRight, .bottomRight: return .right
        }
    }

    public var vertical: Vertical {
        switch self {
        case .topLeft, .topCenter, .topRight: return .top
        case .middleLeft, .center, .middleRight: return .center
        case .bottomLeft, .bottomCenter, .bottomRight: return .bottom
        }
    }
}

public struct WindowCommand: Identifiable, Hashable, Codable {
    public var id = UUID()
    public var name = ""
    public var width: WindowDimension?
    public var height: WindowDimension?
    public var anchor: Anchor = .topLeft
    public var offsetX = WindowDimension.percent(0)
    public var offsetY = WindowDimension.percent(0)

    public init(
        id: UUID = UUID(),
        name: String = "",
        width: WindowDimension? = nil,
        height: WindowDimension? = nil,
        anchor: Anchor = .topLeft,
        offsetX: WindowDimension = .percent(0),
        offsetY: WindowDimension = .percent(0)
    ) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.anchor = anchor
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}

extension WindowCommand {
    public static let seeds: [WindowCommand] = [
        WindowCommand(name: "Left Half", width: .percent(50), height: .percent(100), anchor: .topLeft),
        WindowCommand(name: "Right Half", width: .percent(50), height: .percent(100), anchor: .topRight),
        WindowCommand(name: "Center", width: .percent(60), height: .percent(60), anchor: .center),
        WindowCommand(name: "Top Left Quarter", width: .percent(50), height: .percent(50), anchor: .topLeft),
        WindowCommand(name: "Maximize", width: .percent(100), height: .percent(100), anchor: .topLeft)
    ]
}
