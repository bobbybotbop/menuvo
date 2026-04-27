import Foundation

struct Recipe: Identifiable {
    let id: UUID
    let name: String
    let time: String
    let cuisine: String
    let friendsSaved: Int

    init(id: UUID = UUID(), name: String, time: String, cuisine: String, friendsSaved: Int) {
        self.id = id
        self.name = name
        self.time = time
        self.cuisine = cuisine
        self.friendsSaved = friendsSaved
    }
}
