// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class DeleteUserMutation: GraphQLMutation {
    static let operationName: String = "DeleteUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteUser { private { __typename deleteUser { __typename success errors } } }"#
      ))

    public init() {}

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { API.Objects.Mutation }
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
          .field("deleteUser", DeleteUser?.self),
        ] }

        var deleteUser: DeleteUser? { __data["deleteUser"] }

        /// Private.DeleteUser
        ///
        /// Parent Type: `DeleteUserPayload`
        struct DeleteUser: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.DeleteUserPayload }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("success", Bool?.self),
            .field("errors", [String]?.self),
          ] }

          var success: Bool? { __data["success"] }
          var errors: [String]? { __data["errors"] }
        }
      }
    }
  }

}