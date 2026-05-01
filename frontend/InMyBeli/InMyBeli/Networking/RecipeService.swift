import Foundation

private struct UserRecipesResponse: Decodable {
    let userId: Int
    let recipes: [RecipePreview]

    enum CodingKeys: String, CodingKey {
        case recipes
        case userId = "user_id"
    }
}

private struct FeedResponse: Decodable {
    let recipes: [RecipePreview]
}

final class RecipeService {
    static let shared = RecipeService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchFeed() async throws -> [RecipePreview] {
        let response = try await client.get("feed/recipes/", as: FeedResponse.self)
        return response.recipes
    }

    func fetchRecipes(forUserId userId: Int) async throws -> [RecipePreview] {
        let response = try await client.get(
            "users/\(userId)/recipes/",
            as: UserRecipesResponse.self
        )
        return response.recipes
    }

    func fetchRecipe(id: Int) async throws -> Recipe {
        try await client.get("recipes/\(id)/", as: Recipe.self)
    }

    func createRecipe(
        title: String,
        timeMinutes: Int?,
        servings: Int?,
        cuisine: String?,
        ingredients: [[String: String]],
        instructions: [String],
        imageData: Data?
    ) async throws -> Recipe {
        var fields: [String: String] = ["title": title]
        if let timeMinutes { fields["time_minutes"] = "\(timeMinutes)" }
        if let servings { fields["servings"] = "\(servings)" }
        if let cuisine, !cuisine.isEmpty { fields["cuisine"] = cuisine }

        if !ingredients.isEmpty,
           let jsonData = try? JSONSerialization.data(withJSONObject: ingredients),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            fields["ingredients"] = jsonStr
        }

        if !instructions.isEmpty,
           let jsonData = try? JSONSerialization.data(withJSONObject: instructions),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            fields["instructions"] = jsonStr
        }

        return try await client.postMultipart(
            "recipes/",
            fields: fields,
            imageData: imageData,
            as: Recipe.self
        )
    }
}
