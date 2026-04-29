import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search for recipes or friends"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(Theme.Palette.lightBrown)

            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Theme.Palette.darkBrown)
                .tint(Theme.Palette.lightBrown)
        }
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(Theme.Palette.cream)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.search))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.search)
                .stroke(Theme.Palette.lightBrown.opacity(0.18), lineWidth: 1)
        )
    }
}
