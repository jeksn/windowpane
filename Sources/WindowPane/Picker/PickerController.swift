import WindowPaneCore
import AppKit
import SwiftUI

final class PickerController: NSObject, NSWindowDelegate {
    static let shared = PickerController()

    private var panel: PickerPanel?
    private let viewModel = PickerViewModel()
    private var target: WindowRef?
    private var keyMonitor: Any?

    func toggle() {
        if panel?.isVisible == true {
            close()
        } else {
            show()
        }
    }

    func show() {
        target = WindowManipulator.frontmostWindow()
        viewModel.commands = CommandStore.shared.commands
        viewModel.reset()

        let panel = ensurePanel()
        position(panel)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel?.orderOut(nil)
    }

    private func apply(_ command: WindowCommand) {
        close()
        CommandApplier.shared.apply(command, target: target ?? WindowManipulator.frontmostWindow())
    }

    private func ensurePanel() -> PickerPanel {
        if let panel { return panel }

        let panel = PickerPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 380),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.delegate = self
        panel.contentView = NSHostingView(
            rootView: PickerView(viewModel: viewModel) { [weak self] command in
                self?.apply(command)
            }
        )
        self.panel = panel
        installKeyMonitor()
        return panel
    }

    private func position(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let screen else { return }
        let visible = screen.visibleFrame
        let x = visible.midX - panel.frame.width / 2
        let y = visible.maxY - visible.height * 0.32 - panel.frame.height
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func installKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, let panel = self.panel, panel.isKeyWindow else { return event }
            switch event.keyCode {
            case 125:
                self.viewModel.moveSelection(1)
                return nil
            case 126:
                self.viewModel.moveSelection(-1)
                return nil
            case 36, 76:
                if let command = self.viewModel.selectedCommand() {
                    self.apply(command)
                }
                return nil
            case 53:
                self.close()
                return nil
            default:
                return event
            }
        }
    }

    func windowDidResignKey(_ notification: Notification) {
        close()
    }
}

final class PickerPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}
