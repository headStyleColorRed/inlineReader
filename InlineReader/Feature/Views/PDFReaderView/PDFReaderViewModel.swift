import SwiftUI

class PDFReaderViewModel: ObservableObject {
    @Published var loading = true

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.loading = false
        }
    }
}
