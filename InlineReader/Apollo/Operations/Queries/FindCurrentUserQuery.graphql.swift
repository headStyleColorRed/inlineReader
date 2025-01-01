// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class FindCurrentUserQuery: GraphQLQuery {
    static let operationName: String = "FindCurrentUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FindCurrentUser { private { __typename currentUser { __typename ...UserShortFragment } } }"#,
        fragments: [UserShortFragment.self]
      ))

    public init() {}

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
          .field("currentUser", CurrentUser?.self),
        ] }

        var currentUser: CurrentUser? { __data["currentUser"] }

        /// Private.CurrentUser
        ///
        /// Parent Type: `User`
        struct CurrentUser: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.User }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(UserShortFragment.self),
          ] }

          var id: API.ID { __data["id"] }
          var email: String { __data["email"] }
          var name: String? { __data["name"] }
          var role: Int { __data["role"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var userShortFragment: UserShortFragment { _toFragment() }
          }
        }
      }
    }
  }

}