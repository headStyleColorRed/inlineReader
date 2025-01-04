// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class GetFileAsTxtQuery: GraphQLQuery {
    static let operationName: String = "GetFileAsTxt"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetFileAsTxt($id: ID!) { private { __typename getFileAsTxt(id: $id) { __typename id name url blobId contentType byteSize checksum } } }"#
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
      /// Parent Type: `PrivateQueries`
      struct Private: API.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { API.Objects.PrivateQueries }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("getFileAsTxt", GetFileAsTxt.self, arguments: ["id": .variable("id")]),
        ] }

        var getFileAsTxt: GetFileAsTxt { __data["getFileAsTxt"] }

        /// Private.GetFileAsTxt
        ///
        /// Parent Type: `Document`
        struct GetFileAsTxt: API.SelectionSet {
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