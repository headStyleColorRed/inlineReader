import SwiftUI
import PDFKit
import SwiftData

struct PDFReaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = PDFReaderViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var files: [File]
    @State private var selectedText: SelectedText? = nil
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    private let file: File
    private var horizontalPadding: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 100 : 20
    }

    var selectionActions: SelectionActions {
        return SelectionActions(
            onTranslate: { text in
                selectedText = SelectedText(text: text)
            }, onAnnotate: { text, range in
                guard let file = files.first(where: { $0.id == file.id }) else { return }
                do {
                    file.annotations.append(Annotation(text: text, range: range))
                    try modelContext.save()
                } catch {
                    print("Error saving annotation: \(error)")
                }
            }, onRemoveAnnotation: { annotation in
                guard let file = files.first(where: { $0.id == file.id }) else { return }
                file.annotations.removeAll { $0.id == annotation.id }
            })
    }

    init(file: File) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            HStack {
                SelectableTextView(
                    text: viewModel.pdfText,
                    options: file.settings,
                    annotations: file.annotations,
                    selectionActions: selectionActions
                )
                .defersSystemGestures(on: .all)
                .padding(EdgeInsets(top: 20, leading: horizontalPadding, bottom: 20, trailing: horizontalPadding))
            }
            .withLoader(loading: $viewModel.loading)
            .sheet(item: $selectedText) { text in
                NavigationStack {
                    TranslationView(text: text, settings: file.settings)
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    ReaderSettingsView(file: file)
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
                await viewModel.loadPDFText(file: file)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PDFReaderView(file: File(url: URL(fileURLWithPath: "test.pdf")))
        .modelContainer(for: File.self, inMemory: true)
}
