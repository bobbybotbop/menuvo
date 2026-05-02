import SwiftUI

struct AddRecipeToCookbookSheet: View {
    let cookbook: Cookbook
    let onAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @State private var recipes: [RecipePreview] = []
    @State private var selectedIds: Set<Int> = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var loadError: String?
    @State private var isSaving = false
    @State private var saveError: String?

    private var filtered: [RecipePreview] {
        guard !searchText.isEmpty else { return recipes }
        return recipes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            handle

            VStack(alignment: .leading, spacing: 15) {
                header
                searchBar
                recipeList
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 20)

            Spacer(minLength: 0)

            addButton
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(hex: "FCFCFC"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .task { await load() }
    }

    private var handle: some View {
        Capsule()
            .fill(Theme.Palette.lightBrown)
            .frame(width: 97, height: 4)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        Text("Add Recipe")
            .font(.system(size: 30, weight: .regular))
            .tracking(0.3)
            .foregroundColor(Theme.Palette.darkBrown)
    }

    private var searchBar: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(Theme.Palette.placeholder)
            TextField("Search for specific recipes", text: $searchText)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(Theme.Palette.darkBrown)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(hex: "EFEFEF"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .frame(height: 35)
    }

    @ViewBuilder
    private var recipeList: some View {
        if isLoading && recipes.isEmpty {
            ProgressView().tint(Theme.Palette.lightBrown)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
        } else if let loadError, recipes.isEmpty {
            Text(loadError)
                .font(.system(size: 13))
                .foregroundColor(Theme.Palette.orangeBrown)
                .padding(.top, 12)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filtered) { recipe in
                        recipeRow(recipe)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func recipeRow(_ recipe: RecipePreview) -> some View {
        let isSelected = selectedIds.contains(recipe.id)
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(recipe.title)
                        .font(.system(size: 23, weight: .regular))
                        .tracking(0.23)
                        .foregroundColor(Theme.Palette.darkBrown)
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        if let label = recipe.timeLabel {
                            Text(label)
                                .font(.system(size: 15, weight: .regular))
                                .tracking(0.15)
                                .foregroundColor(Theme.Palette.lightBrown)
                            if recipe.cuisine != nil {
                                Circle()
                                    .fill(Theme.Palette.lightBrown)
                                    .frame(width: 2, height: 2)
                            }
                        }
                        if let cuisine = recipe.cuisine {
                            Text(cuisine)
                                .font(.system(size: 15, weight: .regular))
                                .tracking(0.15)
                                .foregroundColor(Theme.Palette.lightBrown)
                        }
                    }
                }

                Spacer()

                Button {
                    if isSelected {
                        selectedIds.remove(recipe.id)
                    } else {
                        selectedIds.insert(recipe.id)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Theme.Palette.darkBrown : Color.clear)
                            .frame(width: 30, height: 30)
                        Circle()
                            .stroke(Theme.Palette.darkBrown, lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? Theme.Palette.cream : Theme.Palette.darkBrown)
                            .rotationEffect(isSelected ? .degrees(45) : .zero)
                    }
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 20)

            Rectangle()
                .fill(Color(hex: "D0D0D0"))
                .frame(height: 1.5)
        }
    }

    private var addButton: some View {
        Button {
            Task { await save() }
        } label: {
            Group {
                if isSaving {
                    ProgressView().tint(Theme.Palette.cream)
                } else {
                    Text("Add")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Theme.Palette.cream)
                }
            }
            .frame(width: 230, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(selectedIds.isEmpty
                          ? Theme.Palette.darkBrown.opacity(0.4)
                          : Theme.Palette.darkBrown)
            )
        }
        .disabled(selectedIds.isEmpty || isSaving)
    }

    private func load() async {
        guard let userId = session.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            recipes = try await RecipeService.shared.fetchRecipes(forUserId: userId)
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func save() async {
        isSaving = true
        saveError = nil
        defer { isSaving = false }
        do {
            for recipeId in selectedIds {
                try await CookbookService.shared.addRecipe(cookbookId: cookbook.id, recipeId: recipeId)
            }
            onAdded()
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    Color.gray.sheet(isPresented: .constant(true)) {
        AddRecipeToCookbookSheet(cookbook: Cookbook(id: 1, name: "Savory Tastes", description: nil), onAdded: {})
            .presentationDetents([.height(469)])
            .presentationDragIndicator(.hidden)
    }
}
