import PDFKit
import Apollo

extension PDFDocument {
    func asGraphQLFile(fieldName: String, fileName: String) -> GraphQLFile? {
        guard let pdfURL = NSURL(fileURLWithPath:
                                NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".pdf")
        else {
            return nil
        }

        guard let pdfData = self.dataRepresentation(),
              (try? pdfData.write(to: pdfURL)) != nil else {
            return nil
        }

        guard let file = try? GraphQLFile(fieldName: fieldName,
                                        originalName: fileName,
                                        mimeType: "application/pdf",
                                        fileURL: pdfURL) else {
            return nil
        }
        return file
    }
}
