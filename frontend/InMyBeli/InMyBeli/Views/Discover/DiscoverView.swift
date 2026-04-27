import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var recipes: [Recipe] = [
        Recipe(name: "Dish Name", time: "30 min", cuisine: "Italian", friendsSaved: 5),
        Recipe(name: "Dish Name", time: "45 min", cuisine: "Japanese", friendsSaved: 8),
        Recipe(name: "Dish Name", time: "20 min", cuisine: "Mexican", friendsSaved: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                SearchBar(text: $searchText)

                VStack(alignment: .leading, spacing: 30) {
                    Text("Popular Recipes")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.black)

                    VStack(spacing: 24) {
                        ForEach(recipes) { recipe in
                            RecipeCard(recipe: recipe)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 16)
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    DiscoverView()
}
