import SwiftUI
import SwiftData

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var files: [File]
    @State private var readFile: File? = nil

    var filteredFiles: [File] {
        var result = files

        if viewModel.showOnlyUnread {
            result = result.filter { $0.lastOpened == nil }
        }

        return result.sorted { file1, file2 in
            if viewModel.sortByMostRecent {
                switch (file1.lastOpened, file2.lastOpened) {
                case (let date1?, let date2?):
                    return date1 > date2
                case (nil, nil):
                    return file1.dateAdded > file2.dateAdded
                case (nil, _):
                    return false
                case (_, nil):
                    return true
                }
            } else {
                switch (file1.lastOpened, file2.lastOpened) {
                case (let date1?, let date2?):
                    return date1 < date2
                case (nil, nil):
                    return file1.dateAdded < file2.dateAdded
                case (nil, _):
                    return true
                case (_, nil):
                    return false
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filters
            HStack {
                Toggle(isOn: $viewModel.showOnlyUnread) {
                    Text(viewModel.showOnlyUnread ? "Unread" : "All")
                }
                .toggleStyle(.button)
                .tint(.accentColor)

                Spacer()

                Toggle(isOn: $viewModel.sortByMostRecent) {
                    Label(
                        viewModel.sortByMostRecent ? "Most Recent" : "Least Recent",
                        systemImage: viewModel.sortByMostRecent ? "arrow.up" : "arrow.down"
                    )
                }
                .toggleStyle(.button)
                .tint(.accentColor)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))

            if files.isEmpty {
                ContentUnavailableView(
                    "No Files",
                    systemImage: "doc.text",
                    description: Text("Import a file to get started")
                )
            } else {
                List {
                    ForEach(filteredFiles) { file in
                        Button {
                            readFile = file
                        } label: {
                            HStack {
                                if let thumbnailData = file.thumbnailData,
                                   let uiImage = UIImage(data: thumbnailData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: "doc.text.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.accentColor)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.name)
                                        .foregroundStyle(.primary)

                                    if let lastOpened = file.lastOpened {
                                        Text(lastOpened.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Never opened")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.leading, 8)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let url = file.fullURL {
                                    try? FileManager.default.removeItem(at: url)
                                }
                                modelContext.delete(file)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Library")
        .fullScreenCover(item: $readFile) { file in
            TextReaderView(file: file)
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .modelContainer(for: File.self, inMemory: true)
    }
}
