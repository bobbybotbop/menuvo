import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.black.opacity(0.5))

            TextField("Search for recipes or friends", text: $text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.black)
        }
        .frame(height: 37)
        .padding(.horizontal, 10)
        .background(Color(hex: "ebebeb"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
