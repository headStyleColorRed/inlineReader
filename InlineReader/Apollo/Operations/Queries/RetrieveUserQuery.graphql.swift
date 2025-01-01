// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class RetrieveUserQuery: GraphQLQuery {
    static let operationName: String = "RetrieveUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query RetrieveUser($id: ID!) { private { __typename user(id: $id) { __typename id email role name age } } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { API.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("private", Private.self),
      ] }

      var `private`: Private { __data["private"] }

      /// Private
      ///
      /// Parent Type: `Private`
      struct Private: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { API.Objects.Private }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("user", User?.self, arguments: ["id": .variable("id")]),
        ] }

        var user: User? { __data["user"] }

        /// Private.User
        ///
        /// Parent Type: `User`
        struct User: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.User }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("email", String.self),
            .field("role", Int.self),
            .field("name", String?.self),
            .field("age", Int?.self),
          ] }

          var id: API.ID { __data["id"] }
          var email: String { __data["email"] }
          var role: Int { __data["role"] }
          var name: String? { __data["name"] }
          var age: Int? { __data["age"] }
        }
      }
    }
  }

}