//
//  ContentView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isFilePickerPresented = false
    @Query private var files: [File]

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    HomeView()
                } label: {
                    Label("Library", systemImage: "book")
                }

                Button {
                    isFilePickerPresented = true
                } label: {
                    Label("Import", systemImage: "folder")
                }
                .fileImporter(
                    isPresented: $isFilePickerPresented,
                    allowedContentTypes: [UTType.pdf],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let urls):
                        for url in urls {
                            if url.startAccessingSecurityScopedResource() {
                                do {
                                    // Define the destination URL in the app's documents directory
                                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

                                    // Copy the file to the app's documents directory
                                    try FileManager.default.copyItem(at: url, to: destinationURL)

                                    // Create a File object with the new URL and insert it into the context
                                    let file = File(url: destinationURL)
                                    modelContext.insert(file)
                                } catch {
                                    print("Error copying file: \(error.localizedDescription)")
                                }
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                    case .failure(let error):
                        print("Error importing files: \(error.localizedDescription)")
                    }
                }

                Button {
                    // delete all files
                    for file in files {
                        modelContext.delete(file)
                    }
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
        } detail: {
            HomeView()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}
