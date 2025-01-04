//
//  LoggingInterceptor.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 3/1/25.
//

import Foundation
import Apollo
import ApolloAPI
import os.log

// Define loggers at file level
private extension Logger {
    static let responsesLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "InlineReader", category: "GQLResponses")
    static let requestLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "InlineReader", category: "GQLRequests")
}

public class LoggingInterceptor: ApolloInterceptor {
    public var id: String = "LoggingInterceptor"

    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

            print("LoggingInterceptor.interceptAsync()")

            let requestID = request.contextIdentifier ?? UUID()

            print("GraphQL begin request - \(request.operation) (\(requestID)")

//            if let variables = request.operation.__variables?.reduce(into: [String: Any]()) {
//                $0[$1.key] = $1.value._jsonEncodableValue?._jsonValue.base
//            } {
//                self.printResponse(variables, responses: false)
//            }

            // Run the chain and intercept for logging
            chain.proceedAsync(request: request,
                               response: response,
                               interceptor: self,
                               completion: { result in

                // Log json response
                if case let .success(data) = result {
                    self.printResponse(data.asJSONDictionary(), responses: true)
                }
                completion(result)
            })
        }

    private func printResponse(_ result: [String: Any], responses: Bool) {
        // Parse the data and create a string with json format
        guard let json = try? JSONSerialization.data(withJSONObject: result, options: []),
              let jsonString = json.prettyPrintedJSONString else { return }
        // Split the string into an array of lines
        let lines = jsonString.components(separatedBy: .newlines)
        // Filter out the lines that contain "typename" since it doesn't give us any useful data
        let filteredLines = lines.filter { !$0.contains("typename") }
        // Join the remaining lines back into a single string
        let cleanOutput = filteredLines.joined(separator: "\n")
        // Print output
        if responses {
            Logger.responsesLogger.info("\(cleanOutput)")
        } else {
            Logger.requestLogger.info("\(cleanOutput)")
        }

        print(cleanOutput)
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
