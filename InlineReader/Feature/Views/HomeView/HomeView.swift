//
//  HomeView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainViewModel: SidebarViewModel
    @StateObject var viewModel = HomeViewModel()
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
                        Button {
                            readFile = file
                        } label: {
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
                                Spacer()
                            }
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {

                            Button(action: {
                                uploadFile(file: file)
                            }) {
                                Label("Upload PDF", systemImage: "arrow.up.doc")
                            }
//
                            Button(action: {
                                convertFileToTxt(file: file)
                            }) {
                                Label("Convert to txt", systemImage: "document.viewfinder.fill")
                            }

                            Button(role: .destructive) {
                                deleteFile(file: file)
                            } label: {
                                Label("Delete", systemImage: "trash")
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
            viewModel.viewDelegate = self
        }
        .onChange(of: horizontalSizeClass) {
            updateGridColumns()
        }
        .fullScreenCover(item: $readFile) { file in
            TextReaderView(file: file)
                .environmentObject(mainViewModel)
        }
//        .overlay {
//            if isUploading {
//                ProgressView("Uploading PDF...")
//                    .padding()
//                    .background(.regularMaterial)
//                    .cornerRadius(8)
//            }
//        }
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

    private func uploadFile(file: File) {
        Task {
            let document = await viewModel.uploadPDF(file: file)
            guard let file = files.first(where: { $0.id == file.id }) else { return }
            file.document = document
            do {
                try modelContext.save()
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Save error: \(error.localizedDescription)")
            }
        }
    }

    private func convertFileToTxt(file: File) {
        guard file.document != nil else {
            BannerManager.showError(message: "Please upload the PDF first")
            return
        }
        viewModel.convertFileToTxt(file: file)
    }

    private func deleteFile(file: File) {
        modelContext.delete(file)

        Task {
            do {
                guard let documentId = file.document?.id else {
                    throw "Please upload the PDF first, could not find documentId"
                }
                try await viewModel.network.deleteFile(id: documentId)
                try modelContext.save()
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Delete error: \(error.localizedDescription)")

                modelContext.rollback()
            }
        }
    }
}

extension HomeView: HomeViewModelToView {
    func createNewFileFrom(document: Document) {
        do {
            let file = File(from: document)
            modelContext.insert(file)
            try modelContext.save()
        } catch {
            BannerManager.showError(message: error.localizedDescription)
            print("Create new file error: \(error.localizedDescription)")
        }
    }
}

#Preview(traits: .landscapeLeft) {
    SidebarView()
        .modelContainer(for: File.self, inMemory: true)
}
