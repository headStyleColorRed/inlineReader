//
//  Network.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 18/12/24.
//

import Foundation
import Apollo

public class Network {
    public static let shared = Network()

    // Add a property for the ApolloClient
    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: "\(Session.shared.url)/graphql")!
        return ApolloClient(url: url)
    }()

    init() {
        // Initialization code if needed
    }
}
