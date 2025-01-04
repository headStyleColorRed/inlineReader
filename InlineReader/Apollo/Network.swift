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

    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: "\(Session.shared.url)/graphql")!

        let store = ApolloStore()
        let transport = RequestChainNetworkTransport(
            interceptorProvider: NetworkInterceptorProvider(store: store),
            endpointURL: url
        )

        return ApolloClient(networkTransport: transport, store: store)
    }()

    init() {
        // Initialization code if needed
    }
}

public class NetworkInterceptorProvider: DefaultInterceptorProvider {
    public override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        // Get default interceptors
        let interceptors = super.interceptors(for: operation)

        // Remove MaxRetryInterceptor and re-add with more retries allowed
        var myInterceptors = interceptors.filter { interceptor in
            return !(type(of: interceptor) == MaxRetryInterceptor.self)
        }
        myInterceptors.append(MaxRetryInterceptor(maxRetriesAllowed: 20))

        // Add JWT Authentication interceptor
        myInterceptors.insert(JWTAuthenticationInterceptor(), at: 0)
        myInterceptors.insert(LoggingInterceptor(), at: 1)

        return myInterceptors
    }
}
