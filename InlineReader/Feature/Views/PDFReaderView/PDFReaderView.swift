import SwiftUI

struct PDFReaderView: View {
    let file: File

    var body: some View {
        ScrollView {
            Text("PDF Content will go here")
                .padding()
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}
