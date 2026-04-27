import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "e7e7e7"))

            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.name)
                        .font(.system(size: 25, weight: .regular))
                        .tracking(0.25)
                        .foregroundColor(.black)

                    HStack(spacing: 5) {
                        Text(recipe.time)
                            .font(.system(size: 15, weight: .light))
                            .tracking(0.15)
                            .foregroundColor(.black)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 2, height: 2)
                        Text(recipe.cuisine)
                            .font(.system(size: 15, weight: .light))
                            .tracking(0.15)
                            .foregroundColor(.black)
                    }
                }

                HStack(spacing: 5) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 11)
                        .foregroundColor(.black)
                    Text("\(recipe.friendsSaved)+ friends saved")
                        .font(.system(size: 9, weight: .light))
                        .tracking(0.09)
                        .foregroundColor(.black)
                }
            }
            .padding(.leading, 30)
            .padding(.bottom, 30)
        }
        .frame(height: 202)
    }
}
