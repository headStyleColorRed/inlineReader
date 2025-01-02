//
//  LoginNetwork.swift
//  Atrapalista
//
//  Created by Rodrigo Labrador Serrano on 25/8/24.
//

import Foundation
import ObjectMapper

protocol LoginNetworkProtocol {
    func getCurrentUser() async throws -> User
    func login(email: String, password: String) async throws -> User
    func createUser(email: String, password: String) async throws -> User
    func identifyUser(email: String) async throws -> Bool
}

class LoginNetwork: LoginNetworkProtocol {
    func getCurrentUser() async throws -> User {
        let query = API.FindCurrentUserQuery()
        let result = try await Network.shared.apollo.asyncFetch(query: query)
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }
        guard let user = result.data?.private.currentUser?.mapped(User.self) else { throw NSError.parsingError }
        return user
    }

    func login(email: String, password: String) async throws -> User {
        let mutation = API.LoginUserMutation(email: email, password: password)
        let result = try await Network.shared.apollo.asyncPerform(mutation: mutation)
        if let error = result.errors?.first {
            throw error.localizedDescription.asError
        }
        guard let user = result.data?.loginUser?.user?.mapped(User.self) else { throw NSError.parsingError }
        return user
    }

    func createUser(email: String, password: String) async throws -> User {
        let mutation = API.CreateUserMutation(email: email, password: password)
        let result = try await Network.shared.apollo.asyncPerform(mutation: mutation)
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }
        guard let user = result.data?.createUser?.mapped(User.self) else { throw NSError.parsingError }
        return user
    }

    func identifyUser(email: String) async throws -> Bool {
        let query = API.IdentifyUserQuery(email: email)
        let result = try await Network.shared.apollo.asyncFetch(query: query)
        if let errors = result.errors {
            throw errors.first?.localizedDescription.asError ?? NSError.unknownError
        }
        return result.data?.identifyUser ?? false
    }
}
