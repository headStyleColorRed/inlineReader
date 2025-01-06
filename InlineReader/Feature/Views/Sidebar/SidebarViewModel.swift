//
//  SidebarViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 6/1/25.
//

import Foundation
import SwiftUI

class SidebarViewModel: ObservableObject {
    @Published var columnVisibility = NavigationSplitViewVisibility.all
    @Published var isSignInSheetPresented = false
    @Published var isLoading = false

    private var email: String = ""
    private var name: String = ""
    private var password: String = ""

    private let loginNetwork: LoginNetworkProtocol = LoginNetwork()

    init() {
        Task {
            try await retrieveCurrentUser()
        }
    }

    func login() {
        guard !isLoading else { return }
        isLoading = true


        Task {
            do {
                let user = try await loginNetwork.login(email: email, password: password)
                DispatchQueue.main.async {
                    self.isLoading = false
                    Session.shared.currentUser = user
                }
            } catch let error {
                BannerManager.showError(message: error.localizedDescription)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    func createAccount() {
        guard !isLoading else { return }
        isLoading = true

        print("Creating account with email: \(email), and password: \(password)")

        Task {
            do {
                let user = try await loginNetwork.createUser(email: email, password: password)
                DispatchQueue.main.async {
                    print("Account created for user: \(user.email ?? "") with id \(user.id ?? -1)")
                    self.isLoading = false
                    Session.shared.currentUser = user

                }
            } catch let error {
                BannerManager.showError(message: error.localizedDescription)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    func retrieveCurrentUser() async throws -> Bool {
        do {
            let user = try await loginNetwork.getCurrentUser()
            print("Current user retrieved: \(user.email ?? "") with id \(user.id ?? -1)")
            Session.shared.currentUser = user
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
}
