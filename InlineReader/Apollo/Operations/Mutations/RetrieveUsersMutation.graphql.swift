// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class RetrieveUsersMutation: GraphQLMutation {
    static let operationName: String = "RetrieveUsers"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RetrieveUsers($file: Upload!) { private { __typename uploadFile(file: $file) { __typename user { __typename files } } } }"#
      ))

    public var file: Upload

    public init(file: Upload) {
      self.file = file
    }

    public var __variables: Variables? { ["file": file] }

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
          .field("uploadFile", UploadFile?.self, arguments: ["file": .variable("file")]),
        ] }

        var uploadFile: UploadFile? { __data["uploadFile"] }

        /// Private.UploadFile
        ///
        /// Parent Type: `UploadFilePayload`
        struct UploadFile: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.UploadFilePayload }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("user", User?.self),
          ] }

          var user: User? { __data["user"] }

          /// Private.UploadFile.User
          ///
          /// Parent Type: `User`
          struct User: API.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { API.Objects.User }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("files", [String]?.self),
            ] }

            var files: [String]? { __data["files"] }
          }
        }
      }
    }
  }

}