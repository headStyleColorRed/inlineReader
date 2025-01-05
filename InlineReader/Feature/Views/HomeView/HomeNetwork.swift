//
//  HomeNetwork.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 4/1/25.
//

import Foundation
import Apollo

protocol HomeNetworkProtocol {
    func uploadPDF(url: URL, files: [GraphQLFile]) async throws -> Document
    func getFileAsTxt(id: String) async throws -> Document
    func deleteFile(id: String) async throws
    func convertFileToTxt(url: URL, files: [GraphQLFile]) async throws -> Document
}

class HomeNetwork: HomeNetworkProtocol {
    func uploadPDF(url: URL, files: [GraphQLFile]) async throws -> Document {
        let result = try await Network.shared.apollo.asyncUpload(
            operation: API.UploadFileMutation(file: url.lastPathComponent),
            files: files
        )
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }

        guard let document = result.data?.private.uploadFile.mapped(Document.self) else { throw NSError.parsingError }
        return document
    }

    func getFileAsTxt(id: String) async throws -> Document {
        let result = try await Network.shared.apollo.asyncFetch(query: API.GetFileAsTxtQuery(id: id))
        guard let document = result.data?.private.getFileAsTxt.mapped(Document.self) else { throw NSError.parsingError }
        return document
    }

    func convertFileToTxt(url: URL, files: [GraphQLFile]) async throws -> Document {
        let result = try await Network.shared.apollo.asyncUpload(
            operation: API.ConvertFileToTxtMutation(file: url.lastPathComponent),
            files: files
        )
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }

        guard let document = result.data?.private.convertFileToTxt.mapped(Document.self) else { throw NSError.parsingError }
        return document
    }

    func deleteFile(id: String) async throws {
        let result = try await Network.shared.apollo.asyncPerform(mutation: API.DeleteFileMutation(id: id))
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }
    }
}
