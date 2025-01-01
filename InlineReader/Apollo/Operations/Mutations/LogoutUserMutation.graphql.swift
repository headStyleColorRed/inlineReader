// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class LogoutUserMutation: GraphQLMutation {
    static let operationName: String = "LogoutUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LogoutUser { private { __typename logoutUser { __typename success } } }"#
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
          .field("logoutUser", LogoutUser?.self),
        ] }

        var logoutUser: LogoutUser? { __data["logoutUser"] }

        /// Private.LogoutUser
        ///
        /// Parent Type: `LogoutUserPayload`
        struct LogoutUser: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.LogoutUserPayload }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("success", Bool.self),
          ] }

          var success: Bool { __data["success"] }
        }
      }
    }
  }

}