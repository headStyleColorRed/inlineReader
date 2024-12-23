//
//  ContentView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    HomeView()
                } label: {
                    Label("Library", systemImage: "book")
                }

                NavigationLink {
                    HomeView()
                } label: {
                    Label("Import", systemImage: "folder")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                }
            }
        } detail: {
            HomeView()
        }
    }
}

struct DetailView: View {
    var item: File

    var body: some View {
        Text("Item at ")
            .padding()
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}
