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
            t.check(decoded == WindowCommand.seeds, "seed round trip mismatch")
        }

        t.run("Codable.anchorLegacyStringDecodes") {
            let decoded = try JSONDecoder().decode(Anchor.self, from: Data("\"topLeft\"".utf8))
            t.check(decoded == .topLeft, "got \(decoded)")
            let center = try JSONDecoder().decode(Anchor.self, from: Data("\"center\"".utf8))
            t.check(center == .center, "got \(center)")
        }

        t.run("Codable.anchorKeyedRoundTrip") {
            let anchor = Anchor(horizontal: .keep, vertical: .bottom)
            let data = try JSONEncoder().encode(anchor)
            let decoded = try JSONDecoder().decode(Anchor.self, from: data)
            t.check(decoded == anchor, "got \(decoded)")
        }

        t.run("Codable.anchorEncodingShape") {
            let data = try JSONEncoder().encode(Anchor.topLeft)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
            t.check(json == ["horizontal": "left", "vertical": "top"], "got \(String(describing: json))")
        }

        t.run("Codable.commandDecodesWithoutNewFields") {
            let json = #"{"name": "Left Half", "anchor": "topLeft", "width": {"percent": 50}, "height": {"percent": 100}}"#
            let decoded = try JSONDecoder().decode(WindowCommand.self, from: Data(json.utf8))
            t.check(decoded.isDefault == false, "isDefault should default to false")
            t.check(decoded.showInMenuBar == false, "showInMenuBar should default to false")
            t.check(decoded.anchor == .topLeft, "anchor mismatch")
        }

        t.run("Migration.legacySeedSetBecomesDefaultsPreservingIDs") {
            let legacyID = UUID()
            let legacy: [WindowCommand] = [
                WindowCommand(id: legacyID, name: "Left Half", width: .percent(50), height: .percent(100), anchor: .topLeft),
                WindowCommand(name: "Right Half", width: .percent(50), height: .percent(100), anchor: .topRight),
                WindowCommand(name: "Center", width: .percent(60), height: .percent(60), anchor: .center),
                WindowCommand(name: "Top Left Quarter", width: .percent(50), height: .percent(50), anchor: .topLeft),
                WindowCommand(name: "Maximize", width: .percent(100), height: .percent(100), anchor: .topLeft)
            ]

            let migrated = WindowCommand.migratingLegacyCommands(legacy)
            t.check(migrated.count == WindowCommand.seeds.count, "expected full seed set, got \(migrated.count)")
            t.check(migrated.allSatisfy(\.isDefault), "all migrated commands should be defaults")
            let leftHalf = migrated.first { $0.name == "Left Half" }
            t.check(leftHalf?.id == legacyID, "hotkey-bound id should be preserved")
            let center = migrated.first { $0.name == "Center" }
            t.check(center?.width == nil, "Center should adopt keep-size geometry")
        }

        t.run("Migration.legacyCustomCommandsArePreserved") {
            let legacy: [WindowCommand] = [
                WindowCommand(name: "Left Half", width: .percent(50), height: .percent(100), anchor: .topLeft),
                WindowCommand(name: "My Custom", width: .points(500), height: nil, anchor: .middleLeft)
            ]

            let migrated = WindowCommand.migratingLegacyCommands(legacy)
            let custom = migrated.first { $0.name == "My Custom" }
            t.check(custom != nil, "custom command should survive")
            t.check(custom?.isDefault == false, "custom should stay custom")
            t.check(custom?.showInMenuBar == true, "custom should be pinned to menu bar")
            t.check(migrated.contains { $0.name == "Maximize" }, "missing defaults should be added")
        }
    }
}
