import SwiftUI
import SwiftData

struct TextReaderView: View {
    @StateObject private var viewModel: TextReaderViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var files: [File]
    @State private var selectedText: SelectedText? = nil
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    init(file: File) {
        _viewModel = StateObject(wrappedValue: TextReaderViewModel(file: file))
    }

    var selectionActions: SelectionActions {
        return SelectionActions(
            onTranslate: { text in
            selectedText = SelectedText(text: text)
        }, onAnnotate: { text, range in
            guard let file = files.first(where: { $0.id == viewModel.file.id }) else { return }
            do {
                file.annotations.append(Annotation(text: text, range: range))
                try modelContext.save()
            } catch {
                print("Error saving annotation: \(error)")
            }
        }, onRemoveAnnotation: { annotation in
            guard let file = files.first(where: { $0.id == viewModel.file.id }) else { return }
            file.annotations.removeAll { $0.id == annotation.id }
        })
    }

    var body: some View {
        NavigationView {
            HStack {
                SelectableTextView(text: viewModel.text,
                                   options: viewModel.file.settings,
                                   annotations: viewModel.file.annotations,
                                   selectionActions: selectionActions)
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
                    ReaderSettingsView(file: viewModel.file)
                }
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
            viewModel.file.updateLastOpened()
            viewModel.viewDidLoad()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    TextReaderView(file: File(url: URL(fileURLWithPath: "test.txt")))
        .modelContainer(for: File.self, inMemory: true)
}
