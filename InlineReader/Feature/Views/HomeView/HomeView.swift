//
//  HomeView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Query private var files: [File]
    @State private var gridColumns: [GridItem] = []
    @State private var readFile: File? = nil

    var sortedFiles: [File] {
        files.sorted { file1, file2 in
            switch (file1.lastOpened, file2.lastOpened) {
            case (let date1?, let date2?):
                return date1 > date2
            case (nil, nil):
                return file1.dateAdded > file2.dateAdded
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }
    }

    var body: some View {
        ScrollView {
            if files.isEmpty {
                Text("No files available, import a PDF to get started")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(sortedFiles) { file in
                        Button(action: {
                            readFile = file
                        }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemBackground))
                                    .aspectRatio(3/4, contentMode: .fit)
                                    .overlay(
                                        Group {
                                            if let thumbnailData = file.thumbnailData,
                                               let uiImage = UIImage(data: thumbnailData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipped()
                                            } else {
                                                Image(systemName: "doc.text.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.accentColor)
                                                    .padding(20)
                                            }
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 4)
                                    .padding(5)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.name)
                                        .font(.headline)
                                        .lineLimit(2)
                                        .foregroundColor(.primary)
                                    if let lastOpened = file.lastOpened {
                                        Text(lastOpened.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Never opened")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                            }
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                if let url = file.fullURL {
                                    try? FileManager.default.removeItem(at: url)
                                }
                                modelContext.delete(file)
                                try? modelContext.save()
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundStyle(Color.red)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Library")
        .onAppear {
            mainViewModel.columnVisibility = .all
            updateGridColumns()
        }
        .onChange(of: horizontalSizeClass) {
            updateGridColumns()
        }
        .fullScreenCover(item: $readFile) { file in
            TextReaderView(file: file)
                .environmentObject(mainViewModel)
        }
    }

    private func updateGridColumns() {
        if horizontalSizeClass == .compact {
            // iPhone layout
            gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        } else {
            // iPad layout
            gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    Mainview()
        .modelContainer(for: File.self, inMemory: true)
}
