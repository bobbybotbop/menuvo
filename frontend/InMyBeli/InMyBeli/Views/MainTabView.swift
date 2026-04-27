import SwiftUI

enum Tab {
    case discover, create, cookbooks, profile
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .discover

    var body: some View {
        VStack(spacing: 0) {
            selectedTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case .discover:
            DiscoverView()
        case .create:
            Text("Create")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        case .cookbooks:
            Text("Cookbooks")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        case .profile:
            Text("Profile")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
    }
}

struct TabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 25) {
            TabBarItem(icon: "magnifyingglass", label: "Discover", isSelected: selectedTab == .discover) {
                selectedTab = .discover
            }
            TabBarItem(icon: "square.and.pencil", label: "Create", isSelected: selectedTab == .create) {
                selectedTab = .create
            }
            TabBarItem(icon: "book", label: "Cookbooks", isSelected: selectedTab == .cookbooks) {
                selectedTab = .cookbooks
            }
            TabBarItem(icon: "person", label: "Profile", isSelected: selectedTab == .profile) {
                selectedTab = .profile
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "fbfbfb"))
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(label)
                    .font(.system(size: 10, weight: .light))
                    .tracking(0.1)
            }
            .frame(width: 70, height: 55)
            .foregroundColor(isSelected ? .white : .black)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color(hex: "383838"))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
