//
//  OnboardingView.swift
//  RouteToPortugal
//
//  Created by Rodrigo Labrador Serrano on 27/12/24.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var selectedLanguage: AppLanguage = .english
    let pages: [OnboardingPage] = [
        .init(title: "Welcome to TranslatePro",
              subtitle: "A translation app to help students work through foreign texts. Save files in the cloud, annotate, get sentence examples, and much more.",
              imageName: "book",
              buttonText: "Get Started"),

        .init(title: "File Compatibility",
              subtitle: "This app handles only .txt files. Import other file types to process and convert them.",
              imageName: "doc.text",
              buttonText: "Next"),

        .init(title: "Choose Your Language",
              subtitle: "Select your preferred language to continue",
              imageName: "globe",
              buttonText: "Continue",
              isLanguageSelection: true),

        .init(title: "Upgrade to Pro",
              subtitle: "Get unlimited word search, further examples, file conversion, and handle more than one file.",
              imageName: "star",
              buttonText: "Upgrade"),

        .init(title: "Stay Updated",
              subtitle: "Enable notifications to stay updated with the latest features and updates.",
              imageName: "bell.badge",
              buttonText: "Enable Notifications")
    ]

    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "AccentColor")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
    }

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                OnboardingPageView(page: pages[index],
                                   action: {
                    if index == pages.count - 1 {
                        requestNotificationPermission()
                    } else if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }, selectedLanguage: $selectedLanguage)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .navigationBarBackButtonHidden()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                createUser()
            }
        }
    }

    private func createUser() {
        dismiss()
    }
}

#Preview {
    OnboardingView()
}
