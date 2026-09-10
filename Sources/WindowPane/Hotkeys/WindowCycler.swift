import AppKit
import CoreGraphics
import Foundation

enum WindowCycler {
    private static let nextWindowSymbolicHotKeyID = "27"

    static func cycleNext() {
        guard let targetPID = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return }

        let (keyCode, modifiers) = configuredNextWindowShortcut() ?? (CGKeyCode(50), CGEventFlags.maskCommand)

        let source = CGEventSource(stateID: .combinedSessionState)
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else { return }

        keyDown.flags = modifiers
        keyUp.flags = modifiers

        keyDown.postToPid(targetPID)
        usleep(1000)
        keyUp.postToPid(targetPID)
    }

    private static func configuredNextWindowShortcut() -> (CGKeyCode, CGEventFlags)? {
        guard let domain = UserDefaults.standard.persistentDomain(forName: "com.apple.symbolichotkeys"),
              let hotKeys = domain["AppleSymbolicHotKeys"] as? [String: Any],
              let entry = hotKeys[nextWindowSymbolicHotKeyID] as? [String: Any],
              let enabled = entry["enabled"] as? Bool, enabled,
              let value = entry["value"] as? [String: Any],
              let parameters = value["parameters"] as? [Int],
              parameters.count >= 3 else { return nil }

        let keyCode = CGKeyCode(parameters[1])
        let modifierMask = UInt64(parameters[2])

        var flags: CGEventFlags = []
        if modifierMask & 0x100000 != 0 { flags.insert(.maskCommand) }
        if modifierMask & 0x080000 != 0 { flags.insert(.maskAlternate) }
        if modifierMask & 0x040000 != 0 { flags.insert(.maskControl) }
        if modifierMask & 0x020000 != 0 { flags.insert(.maskShift) }

        return (keyCode, flags)
    }
}
