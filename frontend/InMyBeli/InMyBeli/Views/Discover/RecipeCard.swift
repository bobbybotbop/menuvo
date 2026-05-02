import SwiftUI

struct RecipeCard: View {
    let title: String
    let imageUrl: String?
    let timeLabel: String?
    let cuisine: String?

    init(preview: RecipePreview) {
        self.title = preview.title
        self.imageUrl = preview.imageUrl
        self.timeLabel = preview.timeLabel
        self.cuisine = preview.cuisine
    }

    init(title: String, imageUrl: String?, timeLabel: String?, cuisine: String?) {
        self.title = title
        self.imageUrl = imageUrl
        self.timeLabel = timeLabel
        self.cuisine = cuisine
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroImage
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .tracking(0.17)
                    .foregroundColor(Theme.Palette.darkBrown)
                    .lineLimit(1)

                metaLine
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.Palette.darkBrown.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Theme.Palette.darkBrown.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Theme.Palette.placeholder
                }
            }
        } else {
            Theme.Palette.placeholder
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(Theme.Palette.lightBrown.opacity(0.6))
                )
        }
    }

    @ViewBuilder
    private var metaLine: some View {
        let parts = [timeLabel, cuisine].compactMap { $0 }.filter { !$0.isEmpty }
        if !parts.isEmpty {
            HStack(spacing: 6) {
                ForEach(Array(parts.enumerated()), id: \.offset) { index, value in
                    if index > 0 {
                        Circle()
                            .fill(Theme.Palette.lightBrown.opacity(0.6))
                            .frame(width: 2, height: 2)
                    }
                    Text(value)
                        .font(.system(size: 13, weight: .regular))
                        .tracking(0.13)
                        .foregroundColor(Theme.Palette.lightBrown)
                }
            }
        }
    }
}
