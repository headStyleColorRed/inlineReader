//
//  HomeViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 4/1/25.
//

import Foundation
import Apollo
import PDFKit
import UniformTypeIdentifiers

protocol HomeViewModelToView {
    func appendFileToLibrary(file: File)
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var isConverting = false

    var network: HomeNetworkProtocol = HomeNetwork()
    var viewDelegate: HomeViewModelToView?

    func uploadPDF(file: File) async -> Document? {
        var files: [GraphQLFile] = Array.init()

        guard let url = file.fullURL else {
            print("No file URL")
            return nil
        }

        let document = PDFDocument(url: url)
        guard let pdfFile = document?.asGraphQLFile(fieldName: "file", fileName: url.lastPathComponent) else { return nil }

        isUploading = true

        files.append(pdfFile)

        do {
            // Create a new document in the server
            let document = try await network.uploadPDF(url: url, files: files)

            // Update the current file with the server configuration
            BannerManager.showSuccess(message: "File \(document.name ?? "") uploaded successfully")
            isUploading = false
            return document
        } catch {
            BannerManager.showError(message: error.localizedDescription)
            print("Upload error: \(error.localizedDescription)")
        }

        isUploading = false
        return nil
    }

    func getFileAsTxt(file: File) {
        print("1. Starting file get from to TXT")
        isConverting = true

        Task {
            do {
                guard let blobId = file.blobId else {
                    print("Failed to get blobId")
                    throw "Please upload the PDF first, could not find blobId"
                }
                print("2. Converting file with blobId: \(blobId)")
                let document = try await network.getFileAsTxt(id: blobId)
                print("3. File converted successfully on server")
                BannerManager.showSuccess(message: "File \(document.name ?? "") converted to txt successfully")

                try await createFileLocaly(document: document, originalFile: file)

            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Convert error: \(error.localizedDescription)")
            }

            isConverting = false
            print("Conversion process completed")
        }
    }

    func convertFileToTxt(file: File) {
        isConverting = true
        var files: [GraphQLFile] = Array.init()

        guard let url = file.fullURL else { return print("No file URL") }

        let document = PDFDocument(url: url)
        guard let pdfFile = document?.asGraphQLFile(fieldName: "file", fileName: url.lastPathComponent) else { return }

        isUploading = true

        files.append(pdfFile)

        Task {
            do {

                let document = try await network.convertFileToTxt(url: url, files: files)
                print("Document successfully converted in server: \(document.name ?? "")")
                try await createFileLocaly(document: document, originalFile: file)
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Upload error: \(error.localizedDescription)")
            }

            self.isConverting = false
        }
    }

    func createFileLocaly(document: Document, originalFile: File) async throws {
        guard let documentURLString = document.url else {
            print("Document URL not found")
            throw "Could not find the document URL"
        }
        // Download the file from the server and save it to the local file system
        let fileURLString = Session.shared.url + documentURLString
        print("4. Downloading from: \(fileURLString)")

        guard let fileURL = URL(string: fileURLString) else {
            print("Failed to create URL from string: \(fileURLString)")
            throw "Could not create the file URL"
        }
        // Asynchronously fetch the file data
        print("5. Starting file download")
        let (data, _) = try await URLSession.shared.data(from: fileURL)
        let fileData: Data = data
        print("6. File downloaded successfully, size: \(fileData.count) bytes")

        // Save the file to the documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            throw "No documents directory found"
        }

        let destinationURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)
        print("7. Saving file to: \(destinationURL.path)")

        if !FileManager.default.fileExists(atPath: destinationURL.path) {
            // Print the first 100 characters of the file data
            if let fileString = String(data: fileData, encoding: .utf8) {
                print("First 100 characters of file: \(fileString.prefix(100))")
            }

            try fileData.write(to: destinationURL)
            print("8. File saved successfully")
        } else {
            if let fileString = String(data: fileData, encoding: .utf8) {
                print("First 100 characters of file: \(fileString.prefix(100))")
            }
            print("8. File already exists at destination")
        }

        // Create a File object with the Data
        print("9. Generating thumbnail")
        let thumbNailData = originalFile.thumbnailData ?? Data()
        let newFile = File(url: destinationURL, thumbNail: thumbNailData)
        newFile.updateWith(document: document)
        print("10. File object created with thumbnail")

        viewDelegate?.appendFileToLibrary(file: newFile)
        print("11. File added to library")

    }
}
