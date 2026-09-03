# WindowPane

macOS menu-bar utility that applies user-defined window sizes/positions to the focused window (Raycast "Create Command" style). Native Swift 6 + SwiftUI, built with Swift Package Manager only — no Xcode project, works with Command Line Tools.

## Commands

```bash
swift build                  # debug build (app + tests)
swift run WindowPaneTests    # run the test harness (exits non-zero on failure)
Scripts/package_app.sh       # release build + WindowPane.app bundle (ad-hoc signed)
Scripts/dev.sh               # debug build + bundle + relaunch app
Scripts/update.sh            # release build + install to /Applications + relaunch
Scripts/install.sh [--force] # copy WindowPane.app to /Applications
```

There is no `swift test` workflow: this machine has Command Line Tools only (no full Xcode). CLT ships neither XCTest nor a working Swift Testing runtime (test bundles build but the runner discovers zero tests), so tests live in the `WindowPaneTests` executable target and run via `swift run WindowPaneTests`.

## Layout

- `Sources/WindowPaneCore/` — dependency-free logic: `WindowDimension`, `Anchor` (two-axis struct with per-axis `keep` for move-style commands; decodes legacy flat strings like `"topLeft"`), `WindowCommand` (+ `seeds`, + `migratingLegacyCommands`), `LayoutEngine` (pure frame math), `FuzzyMatch`, `WindowPaneURL` parsing, `AppSettings`. All public API — consumed by both the app and tests.
- `Sources/WindowPane/` — app target: AX layer (`Accessibility`, `WindowManipulator`), `CommandApplier` (+ `RestoreStore`), `CommandStore` (versioned JSON at `~/Library/Application Support/WindowPane/commands.json`; v2 = `{version, commands}`, legacy bare arrays migrate via `WindowCommand.migratingLegacyCommands`, which preserves IDs of name-matched commands so hotkeys survive), `HotkeyManager`, menu bar + settings UI, `PickerController`/`PickerView` (Spotlight-style overlay), `HUD` feedback, `URLDispatcher`.
- Commands carry `isDefault` (seeds; sidebar "Defaults" section, restorable via `restoreDefaults()`) and `showInMenuBar` (menu bar only lists pinned commands; toggle in the editor, indicator in the sidebar). New custom commands are pinned by default.
- `Tests/WindowPaneTests/` — custom harness (`TestRunner` + suite files + `main.swift`).

## Notes / gotchas

- **KeyboardShortcuts is pinned to exactly 1.10.0.** Newer 3.x uses SwiftUI `@Entry`/`#Preview` macros whose plugin dylibs (`SwiftUIMacros`, `PreviewsMacros`) do not ship with CLT — builds fail. Also, this environment's GitHub mirror only exposes tags up to v1.10.0.
- `onKeyUp` handlers APPEND (never replace): each command registers exactly once per UUID (`HotkeyManager.registeredCommandIDs`); handlers resolve the command dynamically from the store at fire time, so stale registrations are harmless no-ops. Deleting a command clears its shortcut via `KeyboardShortcuts.setShortcut(nil, for:)`.
- Offset semantics match Raycast: positive X offset moves right, **positive Y offset moves DOWN** (screen convention; the engine subtracts in Cocoa's bottom-left coordinates). Percent sizes/anchors/offsets are relative to `visibleFrame` inset by the global edge gap.
- `AppDelegate` registers the `windowpane://` URL scheme via `NSAppleEventManager` kAEGetURL. The event class/ID and direct-object keyword are hard-coded FourCharCode literals (`0x4755524C` = 'GURL', `0x2D2D2D2D` = '----') to avoid Carbon import issues with CLT.
- `WindowManipulator` uses the private `_AXUIElementGetWindow` (dlsym'd from ApplicationServices) to key restore geometry by CGWindowID; falls back to `pid-title` keys. Same approach as Rectangle/Loop.
- AX coordinates are top-left origin, NSScreen bottom-left; conversion helpers live in `WindowManipulator` (primary screen height based).
- Settings is a custom `Window` scene (id `settings`), not the SwiftUI `Settings` scene — the `showSettingsWindow:` selector is unreliable in menu-bar apps on newer macOS. `MenuContent.openSettingsWindow()` activates the app, calls `openWindow(id:)`, then re-activates and orders the window front.
- The picker panel is `.nonactivatingPanel` so the target app stays frontmost; the target window is captured when the panel opens.
- App icon: none (asset catalogs need Xcode's `actool`). Drop a `Resources/AppIcon.icns` (buildable with `iconutil`) and `package_app.sh` picks it up automatically.
- **Signing**: `package_app.sh` signs ad-hoc by default, which changes the cdhash on every rebuild and invalidates the Accessibility (TCC) grant — after each rebuild the toggle looks ON in System Settings but the app is denied. Fix per rebuild: `tccutil reset Accessibility com.windowpane.app`, re-toggle, relaunch. Permanent fix: create a self-signed Code Signing cert (Keychain Access → Certificate Assistant → Create Certificate, "Self Signed Root") and build with `CODESIGN_IDENTITY="Cert Name" Scripts/package_app.sh`.
- Opening System Settings panes uses `/usr/bin/open` via `Process` (`Accessibility.openSystemSettings()`), trying `x-apple.systemsettings:` then the legacy `x-apple.systempreferences:` scheme (this macOS build only registers the legacy one), then falls back to launching System Settings by bundle ID. `NSWorkspace.shared.open` fails to resolve these schemes when the app is launched from a terminal session.
