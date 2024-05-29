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
            LandingPage()
                .modelContainer(for: Routes.self)
        }
    }
}
