// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class UploadFileMutation: GraphQLMutation {
    static let operationName: String = "UploadFile"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UploadFile($file: Upload!) { private { __typename uploadFile(file: $file) { __typename id name url blobId contentType byteSize checksum } } }"#
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
      /// Parent Type: `PrivateMutations`
      struct Private: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { API.Objects.PrivateMutations }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("uploadFile", UploadFile.self, arguments: ["file": .variable("file")]),
        ] }

        var uploadFile: UploadFile { __data["uploadFile"] }

        /// Private.UploadFile
        ///
        /// Parent Type: `Document`
        struct UploadFile: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.Document }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("name", String.self),
            .field("url", String.self),
            .field("blobId", API.ID.self),
            .field("contentType", String.self),
            .field("byteSize", Int.self),
            .field("checksum", String.self),
          ] }

          var id: API.ID { __data["id"] }
          var name: String { __data["name"] }
          var url: String { __data["url"] }
          var blobId: API.ID { __data["blobId"] }
          var contentType: String { __data["contentType"] }
          var byteSize: Int { __data["byteSize"] }
          var checksum: String { __data["checksum"] }
        }
      }
    }
  }

}