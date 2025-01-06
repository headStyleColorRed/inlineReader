import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let action: () -> Void
    @Binding var selectedLanguage: AppLanguage

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
//                .foregroundColor(.accent)

            Text(page.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if page.isLanguageSelection {
                languageSelectionView
            }

            Spacer()

            Button(action: action) {
                Text(page.buttonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    private var languageSelectionView: some View {
        VStack(spacing: 12) {
            ForEach(AppLanguage.allCases, id: \.self) { language in
                Button(action: { selectedLanguage = language }) {
                    HStack {
                        Text(language.flag)
                            .font(.title)
                        Text(language.rawValue)
                            .font(.body)
                        Spacer()
                        if selectedLanguage == language {
                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundColor(.accent)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedLanguage == language ? Color.blue : Color.gray.opacity(0.3))
                    )
                }
                .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 40)
    }
}
