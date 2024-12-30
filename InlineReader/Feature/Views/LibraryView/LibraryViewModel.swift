import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var showOnlyUnread = false
    @Published var sortByMostRecent = true
}
