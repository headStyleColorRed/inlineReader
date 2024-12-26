import SwiftUI
import PDFKit

struct PDFReaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = PDFReaderViewModel()
    @State private var selectedText: SelectedText? = nil
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    private let file: File
    private var document: PDFDocument? {
        guard let url = file.fullURL else { return nil }
        return PDFDocument(url: url)
    }
    private var lastPage: Int {
        guard let document else { return 0 }
        return document.pageCount - 1
    }
    private var horizontalPadding: CGFloat {
        // If ipad 100 if iphone 20
        return UIDevice.current.userInterfaceIdiom == .pad ? 100 : 20
    }

    init(file: File) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            HStack {
                SelectableTextView(text: viewModel.pdfText, options: file.settings, onTextSelected: { text in
                    print("Text selected")
                    selectedText = SelectedText(text: text)
                })
                .defersSystemGestures(on: .all)
                .padding(EdgeInsets(top: 20, leading: horizontalPadding, bottom: 20, trailing: horizontalPadding))
            }
            .withLoader(loading: $viewModel.loading)
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

                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        guard file.currentPage > 0 else { return }
                        viewModel.changePage(by: -1, file: file)
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(file.currentPage <= 0)

                    Spacer()

                    // Page number
                    Text("\(file.currentPage + 1) / \(lastPage)")

                    Spacer()

                    Button(action: {
                        guard file.currentPage < lastPage else { return }
                        viewModel.changePage(by: +1, file: file)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(file.currentPage >= lastPage)
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
