// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class LoginUserMutation: GraphQLMutation {
    static let operationName: String = "LoginUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LoginUser($email: String!, $password: String!) { loginUser(email: $email, password: $password) { __typename token user { __typename id email role name age } errors } }"#
      ))

    public var email: String
    public var password: String

    public init(
      email: String,
      password: String
    ) {
      self.email = email
      self.password = password
    }

    public var __variables: Variables? { [
      "email": email,
      "password": password
    ] }

    struct Data: API.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { API.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("loginUser", LoginUser?.self, arguments: [
          "email": .variable("email"),
          "password": .variable("password")
        ]),
      ] }

      var loginUser: LoginUser? { __data["loginUser"] }

      /// LoginUser
      ///
      /// Parent Type: `LoginUserPayload`
      struct LoginUser: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { API.Objects.LoginUserPayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("token", String?.self),
          .field("user", User?.self),
          .field("errors", [String].self),
        ] }

        var token: String? { __data["token"] }
        var user: User? { __data["user"] }
        var errors: [String] { __data["errors"] }

        /// LoginUser.User
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