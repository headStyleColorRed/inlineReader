//
//  LoginView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 3/1/25.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = "rodrigo@gmail.com"
    @Published var password = "Navidad1!"
    @Published var confirmPassword = ""
    @Published var isCreatingAccount = false
    @Published var isLoading = false
    @Published var userLogedInCorrectly: Bool = false

    private let loginNetwork: LoginNetworkProtocol = LoginNetwork()

    var isFormValid: Bool {
        if isCreatingAccount {
            return !email.isEmpty && !password.isEmpty && password == confirmPassword
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    var disabledButton: Bool {
        return !isFormValid || isLoading
    }

    func login() {
        guard !isLoading else { return }
        isLoading = true

        print("Logging in with email: \(email) and password: \(password)")

        Task {
            do {
                let user = try await loginNetwork.login(email: email, password: password)
                DispatchQueue.main.async {
                    print("User logged in: \(user.email ?? "") with id \(user.id ?? -1)")
                    self.isLoading = false
                    Session.shared.currentUser = user
                    self.userLogedInCorrectly = true
                }
            } catch let error {
                print(error.localizedDescription)
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
                    self.userLogedInCorrectly = true
                }
            } catch let error {
                print(error.localizedDescription)
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

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @Namespace private var animation

    var body: some View {
        ZStack {
            
            VStack(spacing: 20) {
                Text(viewModel.isCreatingAccount ? "Create Account" : "Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)

                    CustomTextField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: true)

                    if viewModel.isCreatingAccount {
                        CustomTextField(icon: "lock", placeholder: "Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.top, 50)

                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        // Hide keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if viewModel.isCreatingAccount {
                            viewModel.createAccount()
                        } else {
                            viewModel.login()
                        }
                    }
                }) {
                    Text(viewModel.isCreatingAccount ? "Create Account" : "Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!viewModel.disabledButton ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.disabledButton)
                .matchedGeometryEffect(id: "actionButton", in: animation)

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.isCreatingAccount.toggle()
                    }
                }) {
                    Text(viewModel.isCreatingAccount ? "Already have an account? Login" : "Don't have an account? Sign up")
                        .foregroundColor(.blue)
                }.disabled(viewModel.isLoading)
            }
            .padding()
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isCreatingAccount)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.userLogedInCorrectly) {
                Text("")
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
