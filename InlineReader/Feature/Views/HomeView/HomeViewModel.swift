//
//  HomeViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 4/1/25.
//

import Foundation
import Apollo
import PDFKit

protocol HomeViewModelToView {
    func createNewFileFrom(document: Document)
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
            BannerManager.showSuccess(message: "File \(document.name) uploaded successfully")
            isUploading = false
            return document
        } catch {
            BannerManager.showError(message: error.localizedDescription)
            print("Upload error: \(error.localizedDescription)")
        }

        isUploading = false
        return nil
    }

    func convertFileToTxt(file: File) {
        isConverting = true

        Task {
            do {
                guard let blobId = file.document?.blobId else {
                    throw "Please upload the PDF first, could not find blobId"
                }
                let document = try await network.convertFileToTxt(id: blobId)
                BannerManager.showSuccess(message: "File \(document.name ?? "") converted to txt successfully")
                viewDelegate?.createNewFileFrom(document: document)
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Convert error: \(error.localizedDescription)")
            }

            isConverting = false
        }
    }
}
