import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            CommandListView()
                .tabItem { Label("Commands", systemImage: "rectangle.split.2x2") }
            AppShortcutListView()
                .tabItem { Label("App Shortcuts", systemImage: "arrow.right.square") }
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
        }
        .frame(width: 780, height: 560)
    }
}
