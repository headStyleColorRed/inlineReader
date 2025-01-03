// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension API {
  class UploadPdfMutation: GraphQLMutation {
    static let operationName: String = "UploadPdf"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UploadPdf($pdfFile: Upload!, $filename: String!) { private { __typename uploadPdf(name: $filename, pdfFile: $pdfFile) { __typename id name pdfUrl createdAt } } }"#
      ))

    public var pdfFile: Upload
    public var filename: String

    public init(
      pdfFile: Upload,
      filename: String
    ) {
      self.pdfFile = pdfFile
      self.filename = filename
    }

    public var __variables: Variables? { [
      "pdfFile": pdfFile,
      "filename": filename
    ] }

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
          .field("uploadPdf", UploadPdf?.self, arguments: [
            "name": .variable("filename"),
            "pdfFile": .variable("pdfFile")
          ]),
        ] }

        var uploadPdf: UploadPdf? { __data["uploadPdf"] }

        /// Private.UploadPdf
        ///
        /// Parent Type: `UserFile`
        struct UploadPdf: API.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { API.Objects.UserFile }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", API.ID.self),
            .field("name", String.self),
            .field("pdfUrl", String?.self),
            .field("createdAt", API.ISO8601DateTime.self),
          ] }

          var id: API.ID { __data["id"] }
          var name: String { __data["name"] }
          var pdfUrl: String? { __data["pdfUrl"] }
          var createdAt: API.ISO8601DateTime { __data["createdAt"] }
        }
      }
    }
  }

}