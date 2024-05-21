//
//  itinerarymakerApp.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 14/05/24.
//

import SwiftUI
import SwiftData

@main
struct itinerarymakerApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Routes.self)
        }
    }
}
