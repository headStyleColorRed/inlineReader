// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class IdentifyUserQuery: GraphQLQuery {
    static let operationName: String = "IdentifyUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query IdentifyUser($email: String!) { identifyUser(email: $email) }"#
      ))

    public var email: String

    public init(email: String) {
      self.email = email
    }

    public var __variables: Variables? { ["email": email] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { API.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("identifyUser", Bool.self, arguments: ["email": .variable("email")]),
      ] }

      var identifyUser: Bool { __data["identifyUser"] }
    }
  }

}