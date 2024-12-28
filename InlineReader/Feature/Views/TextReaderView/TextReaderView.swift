import SwiftUI

struct TextReaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = TextReaderViewModel()
    @State private var selectedText: SelectedText? = nil
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    private let file: File

    init(file: File) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            HStack {
                SelectableTextView(text: viewModel.text, options: file.settings, onTextSelected: { text in
                    selectedText = SelectedText(text: text)
                })
                .defersSystemGestures(on: .all)
                .padding(EdgeInsets(top: 20,
                                  leading: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 20,
                                  bottom: 20,
                                  trailing: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 20))
            }
            .sheet(item: $selectedText) { text in
                NavigationStack {
                    TranslationView(text: text)
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    PDFReaderSettingsView(file: file)
                }
            }
            .onAppear {
                file.updateLastOpened()
            }
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadText(file: file)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    TextReaderView(file: File(url: URL(fileURLWithPath: "test.txt")))
        .modelContainer(for: File.self, inMemory: true)
}
