//
//  SocialMediaApp.swift
//  SocialMedia
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct SocialMediaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var settings = AppSettings()
    
//    init() {
//        setupFirebase()
//    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.displayAppearance.colorScheme)
        }
    }
}

//private extension SocialMediaApp {
//    func setupFirebase() {
//        FirebaseApp.configure()
//    }
//}
