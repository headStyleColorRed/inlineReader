// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  struct UserShortFragment: API.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment UserShortFragment on User { __typename id email name role }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { API.Objects.User }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", API.ID.self),
      .field("email", String.self),
      .field("name", String?.self),
      .field("role", Int.self),
    ] }

    var id: API.ID { __data["id"] }
    var email: String { __data["email"] }
    var name: String? { __data["name"] }
    var role: Int { __data["role"] }
  }

}