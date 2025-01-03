import Foundation
import Apollo
import ApolloAPI

class CookieInterceptor: ApolloInterceptor {
    public var id: String = "AuthenticationInterceptor"

    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        // Add stored cookie if available
        if let cookie = CookieManager.loadCookie() {
            let cookieString = "\(cookie.name)=\(cookie.value)"
            request.addHeader(name: "Cookie", value: cookieString)
            print("Added cookie to request: \(cookieString)")
        } else {
            print("No cookie found to add to request.")
        }

        chain.proceedAsync(request: request,
                          response: response,
                          interceptor: self) { result in
            // Handle response cookies
            if let httpResponse = response?.httpResponse,
               let fields = httpResponse.allHeaderFields as? [String: String],
               let url = httpResponse.url,
               let cookie = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url).first {
                CookieManager.storeCookie(cookie)
                print("Stored cookie from response: \(cookie)")
            } else {
                print("No cookies found in response to store.")
            }

            completion(result)
        }
    }
}
