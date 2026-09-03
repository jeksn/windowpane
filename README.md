# WindowPane

Raycast-style custom window commands for macOS — as a lightweight, open-source menu-bar app.

Resize and move the focused window into any layout you define — halves, thirds, sixths, or custom percentages with offsets — and trigger your presets with global hotkeys, a Spotlight-style quick picker, or a URL.

## Features

- **Custom window commands** — size in % of the display or absolute points, a two-axis anchor (pin left/center/right and top/center/bottom independently, or keep either axis to build move-style commands), and X/Y offsets with negative values
- **32 built-in commands** — halves, corner quarters, column fourths, thirds, sixths, Maximize / Maximize Height / Maximize Width, Center, Reasonable Size, and Move Left/Right/Up/Down — all editable, hideable, deletable, and restorable
- **Global hotkeys** per command, recorded in-app
- **Quick Picker** — a Spotlight-style overlay with fuzzy search over all commands
- **Menu bar pinning** — choose exactly which commands appear in the menu bar
- **Restore** — undo the last window change, per window
- **Edge gap** — keep windows off the screen edges
- **URL scheme** — apply commands from scripts, shells, or other apps
- **Launch at login**
- Native SwiftUI menu-bar app (no Dock icon, ~zero footprint)

## Requirements

- macOS 13 Ventura or later (developed on macOS 26)
- To build: Xcode Command Line Tools — full Xcode is **not** required

## Install from source

```bash
git clone <repo-url>
cd windowpane
Scripts/package_app.sh        # release build → ./WindowPane.app
Scripts/install.sh --force    # copy to /Applications
```

Launch the app and grant **Accessibility** permission when prompted (System Settings → Privacy & Security → Accessibility). Window control on macOS requires it.

### Stable permissions across rebuilds (recommended)

Ad-hoc–signed builds lose their Accessibility grant on every rebuild (macOS keys the grant to the binary's signature hash). Fix it once by signing with a self-signed certificate:

1. Keychain Access → **Certificate Assistant → Create a Certificate…**
2. Name: `WindowPane Dev` · Identity Type: **Self Signed Root** · Certificate Type: **Code Signing**
3. Export the identity and build:

```bash
echo 'export CODESIGN_IDENTITY="WindowPane Dev"' >> ~/.zshrc
source ~/.zshrc
Scripts/update.sh
```

Alternatively, put the certificate name in `Scripts/codesign-identity` (git-ignored) — the build script picks it up automatically.

Re-grant Accessibility one last time — after that, rebuilds keep the permission.

## Usage

- **Menu bar icon** — lists the commands you've pinned (toggle per command in Settings)
- **Quick Picker** — fuzzy-search all commands; ↑↓ to navigate, Return to apply, Esc to close
- **Settings → Commands** — add, duplicate, delete, and edit commands: name, hotkey, size, anchor, offsets, pinning, with a live preview of the resulting frame
- **Settings → General** — edge gap, picker/restore hotkeys, **actions** (Center, Move Left/Right/Up/Down — parameterless, size-preserving), launch at login, Accessibility status

### URL scheme

```bash
open "windowpane://apply?name=Left%20Half"   # apply a saved command by name
open "windowpane://picker"                   # open the quick picker
open "windowpane://command?position=center&relativeWidth=0.5&relativeHeight=0.5"
```

`command` params mirror Raycast deeplinks: `position` (`topLeft`…`bottomRight`), `absoluteWidth`/`absoluteHeight` (points), `relativeWidth`/`relativeHeight` (fraction of the display), and `absolute`/`relativeXOffset`/`YOffset`.

## Updating

```bash
Scripts/update.sh   # release build → install to /Applications → relaunch
```

## How it works

- The usable area is the screen's `visibleFrame` inset by the edge gap; the anchor pins the window to it, offsets shift the frame, and % sizes are relative to that area
- Windows are moved and resized through the macOS Accessibility API (`AXUIElement`)
- Commands persist in `~/Library/Application Support/WindowPane/commands.json`

## Development

```bash
swift build                  # debug build
swift run WindowPaneTests    # test harness
Scripts/dev.sh               # debug build + relaunch app
Scripts/package_app.sh       # release build + .app bundle
```

Built with Swift Package Manager only — no Xcode project needed. See [AGENTS.md](AGENTS.md) for architecture notes and platform gotchas.

## Acknowledgments

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
- Command set inspired by [Raycast's window management](https://manual.raycast.com/window-management)
