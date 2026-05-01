import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search for recipes or friends"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Theme.Palette.darkBrown)
                .tint(Theme.Palette.lightBrown)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .colorScheme(.light)
    }
}
