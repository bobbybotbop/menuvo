import SwiftUI

struct WelcomeView: View {
    let onCreateAccount: () -> Void
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            Theme.Palette.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                logoAndTagline
                buttons
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 224)
        }
    }

    private var logoAndTagline: some View {
        VStack(spacing: 24) {
            logoBlock
            tagline
        }
    }

    private var logoBlock: some View {
        VStack(spacing: 8) {
            Image("MenuvoLogo")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(height: 96)

            Text("menuvo")
                .font(.system(size: 50, weight: .medium))
                .tracking(1.0)
                .foregroundColor(Theme.Palette.darkBrown)
                .multilineTextAlignment(.center)
        }
    }

    private var tagline: some View {
        Text("Cooking is better with friends. Discover new recipes to make, review, and share.")
            .font(.system(size: 24, weight: .light))
            .tracking(0.48)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }

    private var buttons: some View {
        VStack(spacing: 16) {
            Button(action: onCreateAccount) {
                Text("Create an Account")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Theme.Palette.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Theme.Palette.darkBrown)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onLogin) {
                Text("Login")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Theme.Palette.lightBrown)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Theme.Palette.cream)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Theme.Palette.lightBrown, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    WelcomeView(onCreateAccount: {}, onLogin: {})
}
