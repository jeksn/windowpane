import Foundation
import WindowPaneCore

enum WindowCommandCodableTests {
    static func runAll(_ t: TestRunner) {
        t.run("Codable.dimensionRoundTrip") {
            let dimensions: [WindowDimension] = [.percent(50), .points(512), .percent(-10)]
            for dimension in dimensions {
                let data = try JSONEncoder().encode(dimension)
                let decoded = try JSONDecoder().decode(WindowDimension.self, from: data)
                t.check(decoded == dimension, "round trip failed for \(dimension)")
            }
        }

        t.run("Codable.dimensionEncodingShape") {
            let data = try JSONEncoder().encode(WindowDimension.percent(50))
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Double]
            t.check(json == ["percent": 50], "got \(String(describing: json))")
        }

        t.run("Codable.dimensionDecodingRejectsEmptyObject") {
            t.expectThrows("empty object should not decode") {
                _ = try JSONDecoder().decode(WindowDimension.self, from: Data("{}".utf8))
            }
        }

        t.run("Codable.commandRoundTrip") {
            var command = WindowCommand(name: "Left Half", width: .percent(50), height: .percent(100), anchor: .topRight)
            command.offsetX = .points(-20)
            command.offsetY = .percent(5)
            let data = try JSONEncoder().encode(command)
            let decoded = try JSONDecoder().decode(WindowCommand.self, from: data)
            t.check(decoded == command, "round trip mismatch")
        }

        t.run("Codable.nilDimensionsRoundTrip") {
            let command = WindowCommand(name: "Center", width: nil, height: nil, anchor: .center)
            let data = try JSONEncoder().encode(command)
            let decoded = try JSONDecoder().decode(WindowCommand.self, from: data)
            t.check(decoded.width == nil, "width should be nil")
            t.check(decoded.height == nil, "height should be nil")
            t.check(decoded.anchor == .center, "anchor mismatch")
        }

        t.run("Codable.seedCommandsDecode") {
            let data = try JSONEncoder().encode(WindowCommand.seeds)
            let decoded = try JSONDecoder().decode([WindowCommand].self, from: data)
            t.check(decoded.count == WindowCommand.seeds.count, "count mismatch")
        }
    }
}
