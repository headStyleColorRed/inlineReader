import Foundation
import Apollo
import ApolloAPI

class JWTAuthenticationInterceptor: ApolloInterceptor {
    public var id: String = "AuthenticationInterceptor"

    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        // Add JWT token if available
        if let token = TokenManager.loadToken() {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
            print("Added JWT token to request")
        } else {
            print("No JWT token found to add to request")
        }

        chain.proceedAsync(request: request,
                          response: response,
                          interceptor: self,
                          completion: completion)
    }
}
