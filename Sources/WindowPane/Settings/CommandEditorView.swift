import WindowPaneCore
import SwiftUI
import KeyboardShortcuts

struct CommandEditorView: View {
    @Binding var command: WindowCommand

    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $command.name)
                KeyboardShortcuts.Recorder("Hotkey:", name: HotkeyManager.name(for: command.id))
            }
            Section("Size") {
                DimensionField(label: "Width", dimension: $command.width, allowsKeep: true)
                DimensionField(label: "Height", dimension: $command.height, allowsKeep: true)
            }
            Section("Position") {
                AnchorPickerView(anchor: $command.anchor)
                DimensionField(label: "Offset X", dimension: offsetBinding(\.offsetX), allowsKeep: false)
                DimensionField(label: "Offset Y", dimension: offsetBinding(\.offsetY), allowsKeep: false)
            }
            Section("Preview") {
                PreviewDiagram(command: command)
                    .frame(height: 170)
            }
        }
        .formStyle(.grouped)
    }
    private func offsetBinding(_ keyPath: WritableKeyPath<WindowCommand, WindowDimension>) -> Binding<WindowDimension?> {
        Binding<WindowDimension?>(
            get: { command[keyPath: keyPath] },
            set: { if let value = $0 { command[keyPath: keyPath] = value } }
        )
    }
}

struct DimensionField: View {
    let label: String
    @Binding var dimension: WindowDimension?
    let allowsKeep: Bool

    private enum Mode {
        case keep
        case percent
        case points
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: modeBinding) {
                if allowsKeep {
                    Text("Keep").tag(Mode.keep)
                }
                Text("Percent").tag(Mode.percent)
                Text("Points").tag(Mode.points)
            }
            .labelsHidden()
            .fixedSize()

            if modeBinding.wrappedValue != .keep {
                TextField("Value", value: valueBinding, format: .number)
                    .frame(width: 76)
                    .multilineTextAlignment(.trailing)
                Text(modeBinding.wrappedValue == .percent ? "%" : "pt")
                    .foregroundStyle(.secondary)
                    .frame(width: 22, alignment: .leading)
            } else {
                Text("uses current size")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }

    private var modeBinding: Binding<Mode> {
        Binding(
            get: {
                switch dimension {
                case .percent: return .percent
                case .points: return .points
                case nil: return .keep
                }
            },
            set: { newMode in
                switch newMode {
                case .keep:
                    dimension = nil
                case .percent:
                    dimension = .percent(dimension?.value ?? 50)
                case .points:
                    dimension = .points(dimension?.value ?? 400)
                }
            }
        )
    }

    private var valueBinding: Binding<Double> {
        Binding(
            get: { dimension?.value ?? 0 },
            set: { newValue in
                switch dimension {
                case .percent: dimension = .percent(newValue)
                case .points: dimension = .points(newValue)
                case nil: dimension = .percent(newValue)
                }
            }
        )
    }
}

struct AnchorPickerView: View {
    @Binding var anchor: WindowPaneCore.Anchor

    private var rows: [[WindowPaneCore.Anchor]] {
        [
            [.topLeft, .topCenter, .topRight],
            [.middleLeft, .center, .middleRight],
            [.bottomLeft, .bottomCenter, .bottomRight]
        ]
    }

    var body: some View {
        HStack {
            Text("Anchor")
            Spacer()
            VStack(spacing: 3) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 3) {
                        ForEach(row, id: \.self) { cell in
                            Button {
                                anchor = cell
                            } label: {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(anchor == cell ? Color.accentColor : Color.secondary.opacity(0.25))
                                    .frame(width: 28, height: 18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct PreviewDiagram: View {
    let command: WindowCommand

    var body: some View {
        GeometryReader { geo in
            let area = CGRect(x: 0, y: 0, width: geo.size.width, height: geo.size.height)
            let currentFrame = area.insetBy(dx: area.width * 0.25, dy: area.height * 0.25)
            let target = LayoutEngine.frame(for: LayoutEngine.Request(
                usableArea: area,
                currentFrame: currentFrame,
                width: command.width,
                height: command.height,
                anchor: command.anchor,
                offsetX: command.offsetX,
                offsetY: command.offsetY
            ))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.secondary.opacity(0.4)))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor.opacity(0.5))
                    .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(Color.accentColor))
                    .frame(width: max(2, target.width), height: max(2, target.height))
                    .offset(x: target.minX, y: area.height - target.maxY)
            }
        }
    }
}
