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

class MainViewModel: ObservableObject {
    @Published var columnVisibility = NavigationSplitViewVisibility.all
}

struct Mainview: View {
    @StateObject private var viewModel = MainViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var isFilePickerPresented = false
    @State private var navigationDestination: NavigationDestination?
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
        } detail: {
            HomeView()
                .environmentObject(viewModel)
        }
        .onAppear {
            guard !files.isEmpty else { return }
            navigationDestination = .home
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

#Preview(traits: .landscapeLeft) {
    Mainview()
        .modelContainer(for: File.self, inMemory: true)
}
