import SwiftUI

struct ContentView: View {
    @State private var model = FindingViewModel()

    var body: some View {
        Group {
            if model.hasActiveSession {
                FindingMainView(model: model)
                    .transition(.opacity)
            } else {
                LoginView(model: model)
                    .transition(.opacity)
            }
        }
        .environment(\.locale, model.profile.language.locale)
        .preferredColorScheme(model.profile.theme.colorScheme)
        .animation(.easeInOut(duration: 0.25), value: model.hasActiveSession)
        .task {
            guard model.researches.isEmpty else { return }
            await model.load()
        }
    }
}

private enum FindingTab: Hashable {
    case home
    case saved
    case profile

    var title: String {
        switch self {
        case .home: "Home"
        case .saved: "Saved"
        case .profile: "Profile"
        }
    }

    var outlineIcon: String {
        switch self {
        case .home: "house"
        case .saved: "bookmark"
        case .profile: "person"
        }
    }

    var filledIcon: String {
        switch self {
        case .home: "house.fill"
        case .saved: "bookmark.fill"
        case .profile: "person.fill"
        }
    }
}

private struct FindingMainView: View {
    let model: FindingViewModel
    @State private var selectedTab = FindingTab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FeedView(model: model)
                    .onAppear { model.activateTabBar() }
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(FindingTab.home)

            NavigationStack {
                SavedStudiesView(model: model)
                    .onAppear { model.activateTabBar() }
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(FindingTab.saved)

            NavigationStack {
                ProfileView(model: model)
                    .onAppear { model.activateTabBar() }
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(FindingTab.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: model.showsTabBar ? 64 : 0)
        }
        .overlay(alignment: .bottom) {
            if model.showsTabBar {
                FindingTabBar(selection: $selectedTab)
                    .padding(.bottom, 6)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if model.isTabBarAvailable {
                Button {
                    model.showTabBarTemporarily()
                } label: {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Show navigation")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.showsTabBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { _ in model.showTabBarTemporarily() }
        )
        .onChange(of: selectedTab) { _, _ in
            model.showTabBarTemporarily()
        }
    }
}

private struct FindingTabBar: View {
    @Binding var selection: FindingTab

    var body: some View {
        HStack {
            ForEach([FindingTab.home, .saved, .profile], id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    Image(systemName: selection == tab ? tab.filledIcon : tab.outlineIcon)
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .contentTransition(.symbolEffect(.replace))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(selection == tab ? Color.primary : Color.secondary)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 7)
        .frame(maxWidth: 760)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(red: 0.65, green: 0.76, blue: 1).opacity(0.2))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.42), lineWidth: 0.7)
        }
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        .padding(.horizontal, 27)
    }
}

private extension AppTheme {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

private extension AppLanguage {
    var locale: Locale {
        switch self {
        case .system: .current
        case .english: Locale(identifier: "en")
        case .russian: Locale(identifier: "ru")
        }
    }
}

#Preview {
    ContentView()
}
