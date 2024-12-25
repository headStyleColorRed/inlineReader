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
    @Query private var files: [File]
    @State private var gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
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
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(sortedFiles) { file in
                        Button(action: {
                            readFile = file
                        }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .aspectRatio(3/4, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "doc.text.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.blue)
                                            .padding(20)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.name)
                                        .font(.headline)
                                        .lineLimit(2)
                                        .foregroundColor(.black)
                                    if let lastOpened = file.lastOpened {
                                        Text("Last opened: \(lastOpened.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    } else {
                                        Text("Never opened")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }

                                    ProgressView(value: Double(file.progress) / 100)
                                        .tint(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                modelContext.delete(file)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .onAppear {
                                print("Context menu appeared")
                            }

                            Button(action: {
                                file.progress = 0
                            }) {
                                Label("Reset Progress", systemImage: "arrow.counterclockwise")
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
        }
        .fullScreenCover(item: $readFile) { file in
            PDFReaderView(file: file)
                .environmentObject(mainViewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    Mainview()
        .modelContainer(for: File.self, inMemory: true)
}
