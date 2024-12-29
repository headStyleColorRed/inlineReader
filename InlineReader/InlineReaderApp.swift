//
//  InlineReaderApp.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import SwiftUI
import SwiftData

@main
struct InlineReaderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            File.self,
            Settings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Mainview()
        }
        .modelContainer(sharedModelContainer)
    }
}
