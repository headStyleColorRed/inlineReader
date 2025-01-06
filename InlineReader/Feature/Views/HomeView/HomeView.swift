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
    @Query private var files: [File]
    @EnvironmentObject var mainViewModel: SidebarViewModel
    @StateObject var viewModel = HomeViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var gridColumns: [GridItem] = []
    @State private var readFile: File? = nil
    @State private var showAlert = false


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
                Text("No files available, import a TXT or PDF file to get started")
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
                                        }.overlay(alignment: .bottom) {
                                            HStack {
                                                Text("\(file.urlExtension)")
                                                    .bold()
                                                    .font(.system(size: 12))
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                                            .opacity(0.4)
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 4)
                                    .padding(5)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fileName(file: file))
                                        .font(.headline)
                                        .lineLimit(2)
                                        .foregroundColor(.primary)
                                    if let lastOpened = file.lastOpened {
                                        Text(lastOpened.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        HStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 8, height: 8)
                                            Text("Never opened")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
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
                            if canConvertFileToTxt(file: file) {
                                Button(action: {
                                    convertFileToTxt(file: file)
                                }) {
                                    Label("Convert to txt", systemImage: "document.viewfinder.fill")
                                }
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
        .overlay {
            if viewModel.isUploading || viewModel.isConverting {
                ProgressView(viewModel.isUploading ? "Uploading PDF..." : "Converting to txt...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isUploading || viewModel.isConverting)
            }
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

    private func uploadFile(file: File) {
        Task {
            let document = await viewModel.uploadPDF(file: file)
            guard let document, let file = files.first(where: { $0.id == file.id }) else { return }
            file.updateWith(document: document)
            do {
                try modelContext.save()
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Save error: \(error.localizedDescription)")
            }
        }
    }

    private func convertFileToTxt(file: File) {
        viewModel.convertFileToTxt(file: file)
    }

    private func deleteFile(file: File) {
        // Delete the file from the model context
        modelContext.delete(file)

        // Define a function to save the context
        let saveContext: () -> Void = {
            do {
                try modelContext.save()
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Delete error: \(error.localizedDescription)")
                modelContext.rollback()
            }
        }

        // Remove the file from the file system
        if let fileURL = file.fullURL {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("File removed from documents directory")
            } catch {
                print("Error removing file from documents directory: \(error.localizedDescription)")
            }
        }

        // Save the context if the file is not on the server
        if file.serverId == nil {
            saveContext()
        }

        // If the file is on the server, delete it from there as well
        Task {
            do {
                guard let documentId = file.serverId else {
                    throw "Please upload the PDF first, could not find documentId"
                }
                try await viewModel.network.deleteFile(id: documentId)
                saveContext()
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                if error.localizedDescription.contains("Couldn't find Document") {
                    saveContext()
                    return
                }
                print("Delete error: \(error.localizedDescription)")
                modelContext.rollback()
            }
        }
    }

    func canUploadFile(file: File) -> Bool {
        guard let contentType = file.fullURL?.fileType else { return false }
        return file.serverId == nil && contentType == .pdf
    }

    func canConvertFileToTxt(file: File) -> Bool {
        guard let contentType = file.fullURL?.fileType else { return false }
        // Check that the file with same name but with .txt extension doesn't exist in the [File]
        let txtFile = files.first(where: {
            $0.name == file.name && $0.fullURL?.fileType == .text
        })
        return contentType == .pdf && txtFile == nil
    }

    func fileName(file: File) -> String {
        guard let url = file.fullURL, url.fileType == .text else { return file.name ?? "" }
        return (file.name ?? "")

    }
}

extension HomeView: HomeViewModelToView {
    func appendFileToLibrary(file: File) {
        do {
            modelContext.insert(file)
            try modelContext.save()
        } catch {
            BannerManager.showError(message: error.localizedDescription)
            print("Append file error: \(error.localizedDescription)")
        }
    }
}

enum FileType: String, CaseIterable, Identifiable {
    case text = "Text"
    case pdf = "PDF"

    var id: String { self.rawValue }
    var asUTType: UTType {
        switch self {
        case .text:
            return UTType.text
        case .pdf:
            return UTType.pdf
        }
    }
}
