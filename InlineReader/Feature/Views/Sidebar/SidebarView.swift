//
//  ContentView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import PDFKit
import AuthenticationServices

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

    func identifyUser(email: String) {
        guard !isLoading else { return }
        isLoading = true


        Task {
            do {
                let user = try await loginNetwork.identifyUser(email: email)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
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

struct SidebarView: View {
    @StateObject private var viewModel = SidebarViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var isFilePickerPresented = false
    @State private var navigationDestination: NavigationDestination?
    @State var isOnboardingPresented = false
    @Query private var files: [File]

    enum NavigationDestination: Hashable {
        case home
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $viewModel.columnVisibility) {
            List {
                NavigationLink {
                    HomeView()
                        .environmentObject(viewModel)
                } label: {
                    Label("Library", systemImage: "books.vertical")
                }

                Button {
                    isFilePickerPresented = true
                } label: {
                    Label("Import", systemImage: "folder")
                }
                .fileImporter(isPresented: $isFilePickerPresented,
                              allowedContentTypes: [UTType.pdf, UTType.plainText],
                              allowsMultipleSelection: false) { result in
                    fileImported(result: result)
                }
            }
            .navigationDestination(item: $navigationDestination) { destination in
                switch destination {
                case .home:
                    HomeView()
                        .environmentObject(viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isSignInSheetPresented = true
                    }) {
                        Image(systemName: "person.circle")
                    }
                }
            }
        } detail: {
            HomeView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $viewModel.isSignInSheetPresented) {
            LoginView()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingView()
        }
        .onAppear {
            showOnboardingIfNeeded()
        }
    }

    // Will show the onboarding view if it is the first time the user is using the app
    private func showOnboardingIfNeeded() {
        // Check UserDefaults to see if the user has already seen the onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if true !hasSeenOnboarding {
            // Show the onboarding view
            isOnboardingPresented = true
            // Set the hasSeenOnboarding flag to true
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
    }

    func fileImported(result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            if url.startAccessingSecurityScopedResource() {
                do {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                            in: .userDomainMask).first else {
                        throw "No documents directory found"
                    }

                    // Define the destination URL in the app's documents directory
                    let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

                    // If file does not exist at destination, copy it
                    if !FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                    }

                    // If file is not in the model context, add it
                    if !files.contains(File(url: destinationURL)) {
                        let thumbNailData = generateThumbnail(url: destinationURL, fileType: url.fileType)
                        let file = File(url: destinationURL, thumbNail: thumbNailData)
                        print("Imported file:")
                        print(file)
                        modelContext.insert(file)
                    }
                } catch {
                    print("Error copying file: \(error.localizedDescription)")
                }
                url.stopAccessingSecurityScopedResource()
                navigationDestination = .home
            }

        case .failure(let error):
            print("Error importing files: \(error.localizedDescription)")
        }
    }

    private func generateThumbnail(url: URL, fileType: UTType?) -> Data? {

        switch fileType {
        case .pdf:
            if let pdfDocument = PDFDocument(url: url),
               let pdfPage = pdfDocument.page(at: 0) {
                let pageRect = pdfPage.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let thumbnailImage = renderer.image { context in
                    UIColor.systemBackground.set()
                    context.fill(pageRect)
                    context.cgContext.translateBy(x: 0, y: pageRect.height)
                    context.cgContext.scaleBy(x: 1.0, y: -1.0)
                    pdfPage.draw(with: .mediaBox, to: context.cgContext)
                }
                return thumbnailImage.jpegData(compressionQuality: 0.7)
            }
        case .text:
            let textThumbnail = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 400)).image { context in
                // Draw background
                UIColor.systemBackground.setFill()
                context.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 400)))

                // Draw text lines
                UIColor.label.setStroke()
                let lineSpacing: CGFloat = 20
                for y in stride(from: 40, through: 360, by: lineSpacing) {
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: 40, y: y))
                    linePath.addLine(to: CGPoint(x: 260, y: y))
                    linePath.stroke()
                }
            }
            return textThumbnail.jpegData(compressionQuality: 1.0)
        default:
            return nil
        }

        return nil
    }
}

struct SignInView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)

            // Add the subtext here
            Text("Choose a sign in method to create or access your account. Your account will sync your reading progress across devices and track your reading time.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        print("Authorization successful: \(authResults)")
                        // Handle successful sign in

                    case .failure(let error):
                        print("Authorization failed: \(error.localizedDescription)")
                        // Until our developer portal is available we will use the following code to sign in
                        // This code will be removed once the developer portal is available

                    }
                }
            )
            .frame(height: 44)
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

#Preview() {
    SidebarView()
        .modelContainer(for: File.self, inMemory: true)
}
