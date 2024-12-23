//
//  ContentView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isFilePickerPresented = false
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
                                let file = File(url: url)
                                modelContext.insert(file)
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                    case .failure(let error):
                        print("Error importing files: \(error.localizedDescription)")
                    }
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


import UniformTypeIdentifiers

struct ImportView: View {

    var body: some View {
        VStack {
            Button("Select PDF Files") {
            }
        }
        .navigationTitle("Import PDFs")
    }
}
