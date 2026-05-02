import SwiftUI

private enum ProfileSection: String, CaseIterable {
    case reviews = "Reviews"
    case requests = "Requests"
}

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    @State private var selectedSection: ProfileSection = .reviews
    @State private var recipes: [RecipePreview] = []
    @State private var friendRequests: [FriendRequest] = []
    @State private var friendCount = 0
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    profileHeader

                    VStack(spacing: 24) {
                        sectionPicker
                        sectionContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(Color.white)
            .scrollIndicators(.hidden)
            .navigationDestination(for: RecipePreview.self) { preview in
                RecipeDetailView(preview: preview)
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 24) {
            avatarView(urlString: session.currentUser?.profileURL, size: 100)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.currentUser?.name ?? "—")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Theme.Palette.darkBrown)

                    if let user = session.currentUser {
                        Text("@\(user.username)")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "888888"))
                    }
                }

                HStack(spacing: 32) {
                    statView(count: friendCount, label: "friends")
                    statView(count: recipes.count, label: "recipes")
                }
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func avatarView(urlString: String?, size: CGFloat) -> some View {
        let placeholder = Circle()
            .fill(Theme.Palette.placeholder)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.44, weight: .light))
                    .foregroundColor(Theme.Palette.lightBrown)
            )

        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private func statView(count: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "575757"))
        }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        HStack(spacing: 32) {
            ForEach(ProfileSection.allCases, id: \.self) { section in
                tabButton(for: section)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func tabButton(for section: ProfileSection) -> some View {
        let isSelected = selectedSection == section
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedSection = section
            }
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    if section == .requests, friendRequests.count > 0 {
                        requestBadge(count: friendRequests.count, isSelected: isSelected)
                    }
                    Text(section.rawValue)
                        .font(.system(size: 15, weight: isSelected ? .medium : .light))
                        .foregroundColor(.black)
                }
                Rectangle()
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(height: 1.5)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }

    private func requestBadge(count: Int, isSelected: Bool) -> some View {
        Text("\(count)")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(isSelected ? Theme.Palette.orangeBrown : Theme.Palette.cream)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.Palette.cream : Theme.Palette.orangeBrown)
            )
            .overlay(
                Capsule()
                    .stroke(Theme.Palette.orangeBrown, lineWidth: isSelected ? 1 : 0)
            )
    }

    // MARK: - Section Content

    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .reviews:
            reviewsContent
        case .requests:
            requestsContent
        }
    }

    @ViewBuilder
    private var reviewsContent: some View {
        emptyState(icon: "star", message: "No reviews yet.\nRate recipes you've tried!")
    }

    @ViewBuilder
    private var requestsContent: some View {
        if isLoading && friendRequests.isEmpty {
            loadingView
        } else if friendRequests.isEmpty {
            emptyState(icon: "person.2", message: "No pending friend requests.")
        } else {
            VStack(spacing: 16) {
                ForEach(friendRequests) { request in
                    FriendRequestRow(request: request) {
                        await handleAccept(request)
                    } onDecline: {
                        await handleDecline(request)
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        ProgressView()
            .tint(Theme.Palette.lightBrown)
            .frame(maxWidth: .infinity)
            .padding(.top, 48)
    }

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Theme.Palette.lightBrown.opacity(0.45))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    // MARK: - Actions

    private func load() async {
        guard let userId = session.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }

        async let recipesTask: [RecipePreview] = RecipeService.shared.fetchRecipes(forUserId: userId)
        async let requestsTask: [FriendRequest] = FriendService.shared.fetchFriendRequests()
        async let friendsTask: [FriendCandidate] = FriendService.shared.fetchFriends(userId: userId)

        do { recipes = try await recipesTask } catch {}
        do { friendRequests = try await requestsTask } catch {}
        do { friendCount = (try await friendsTask).count } catch {}
    }

    private func handleAccept(_ request: FriendRequest) async {
        do {
            try await FriendService.shared.acceptFriendRequest(requestId: request.id)
            friendRequests.removeAll { $0.id == request.id }
            friendCount += 1
        } catch {
            print("[ProfileView] Accept failed: \(error)")
        }
    }

    private func handleDecline(_ request: FriendRequest) async {
        do {
            try await FriendService.shared.declineFriendRequest(requestId: request.id)
            friendRequests.removeAll { $0.id == request.id }
        } catch {
            print("[ProfileView] Decline failed: \(error)")
        }
    }
}

// MARK: - FriendRequestRow

struct FriendRequestRow: View {
    let request: FriendRequest
    let onAccept: () async -> Void
    let onDecline: () async -> Void

    @State private var isProcessing = false

    private var initial: String {
        let s = request.sender.name ?? request.sender.username
        return String(s.prefix(1)).uppercased()
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.Palette.placeholder)
                .frame(width: 56, height: 56)
                .overlay(
                    Text(initial)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Theme.Palette.lightBrown)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(request.sender.name ?? request.sender.username)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.Palette.darkBrown)
                    .lineLimit(1)
                Text("@\(request.sender.username)")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if isProcessing {
                ProgressView()
                    .tint(Theme.Palette.lightBrown)
                    .frame(width: 20, height: 20)
            } else {
                HStack(spacing: 8) {
                    Button {
                        isProcessing = true
                        Task {
                            await onAccept()
                            isProcessing = false
                        }
                    } label: {
                        Text("Accept")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.Palette.cream)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.Palette.darkBrown)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        isProcessing = true
                        Task {
                            await onDecline()
                            isProcessing = false
                        }
                    } label: {
                        Text("Deny")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "A4A4A4"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "F6F6F6"))
                            .overlay(
                                Capsule().stroke(Color(hex: "A4A4A4"), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "F6F6F6"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 2, y: 4)
    }
}
