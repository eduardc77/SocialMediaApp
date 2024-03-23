//
//  SocialMediaApp.swift
//  SocialMedia
//

import SwiftUI
import FirebaseCore

@main
struct SocialMediaApp: App {
    @StateObject private var settings = AppSettings()
    
    init() {
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.displayAppearance.colorScheme)
        }
    }
}

private extension SocialMediaApp {
    func setupFirebase() {
        FirebaseApp.configure()
    }
}
