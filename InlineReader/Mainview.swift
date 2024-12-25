//
//  ContentView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    @Published var columnVisibility = NavigationSplitViewVisibility.all
}

struct Mainview: View {
    @StateObject private var viewModel = MainViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var isFilePickerPresented = false
    @Query private var files: [File]

    var body: some View {
        NavigationSplitView(columnVisibility: $viewModel.columnVisibility) {
            List {
                NavigationLink {
                    HomeView()
                        .environmentObject(viewModel)
                } label: {
                    Label("Library", systemImage: "book")
                }

                Button {
                    isFilePickerPresented = true
                } label: {
                    Label("Import", systemImage: "folder")
                }
                .fileImporter(isPresented: $isFilePickerPresented,
                              allowedContentTypes: [UTType.pdf],
                              allowsMultipleSelection: false) { result in
                    fileImported(result: result)
                }
            }
        } detail: {
            HomeView()
                .environmentObject(viewModel)
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
                        let file = File(url: destinationURL)
                        print("Imported file:")
                        print(file)
                        modelContext.insert(file)
                    }
                } catch {
                    print("Error copying file: \(error.localizedDescription)")
                }
                url.stopAccessingSecurityScopedResource()
            }

        case .failure(let error):
            print("Error importing files: \(error.localizedDescription)")
        }
    }
}

#Preview(traits: .landscapeLeft) {
    Mainview()
        .modelContainer(for: File.self, inMemory: true)
}
