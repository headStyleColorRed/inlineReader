// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class DeleteFileMutation: GraphQLMutation {
    static let operationName: String = "DeleteFile"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteFile($id: ID!) { private { __typename deleteFile(id: $id) } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

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
      /// Parent Type: `PrivateMutations`
      struct Private: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { API.Objects.PrivateMutations }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("deleteFile", Bool.self, arguments: ["id": .variable("id")]),
        ] }

        var deleteFile: Bool { __data["deleteFile"] }
      }
    }
  }

}