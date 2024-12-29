import SwiftUI

struct TextReaderView: View {
    @StateObject private var viewModel: TextReaderViewModel
    @State private var selectedText: SelectedText? = nil
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    init(file: File) {
        _viewModel = StateObject(wrappedValue: TextReaderViewModel(file: file))
    }

    var body: some View {
        NavigationView {
            HStack {
                SelectableTextView(text: viewModel.text, options: viewModel.file.settings, onTextSelected: { text in
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
                    TranslationView(text: text, settings: viewModel.file.settings)
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    PDFReaderSettingsView(file: viewModel.file)
                }
            }
            .onAppear {
                viewModel.file.updateLastOpened()
            }
            .navigationTitle(viewModel.file.name)
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
                await viewModel.loadText(file: viewModel.file)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    TextReaderView(file: File(url: URL(fileURLWithPath: "test.txt")))
        .modelContainer(for: File.self, inMemory: true)
}
