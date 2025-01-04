//
//  HomeViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 4/1/25.
//

import Foundation
import Apollo
import PDFKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isUploading = false


    func uploadPDF(file: File) {
        var files: [GraphQLFile] = Array.init()

        guard let url = file.fullURL else {
            return print("No file URL")
        }

        let document = PDFDocument(url: url)
        guard let pdfFile = document?.asGraphQLFile(fieldName: "file", fileName: url.lastPathComponent) else { return }

        isUploading = true

        files.append(pdfFile)

        Task {
            do {
                let result = try await Network.shared.apollo.asyncUpload(
                    operation: API.UploadFileMutation(file: url.lastPathComponent),
                    files: files
                )
                if let errors = result.errors {
                    throw errors.first?.localizedDescription.asError ?? NSError.unknownError
                }

                print(result)
                let resulta = result.data?.private.uploadFile?.url
                print(resulta)

                // Handle success or failure
            } catch {
                BannerManager.showError(message: error.localizedDescription)
                print("Upload error: \(error.localizedDescription)")
            }

            isUploading = false
        }
    }

    func convertFileToTxt(file: File) {

    }
}
