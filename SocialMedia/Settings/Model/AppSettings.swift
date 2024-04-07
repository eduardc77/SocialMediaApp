//
//  AppSettings.swift
//  SocialMedia
//

import SwiftUI

final class AppSettings: ObservableObject {
    
    enum DisplayAppearance: String, Identifiable, CaseIterable {
        case system
        case light
        case dark
        
        var id: DisplayAppearance { self }
    }
    
    enum Theme: String, Identifiable, CaseIterable {
        case red
        case orange
        case green
        case mint
        case teal
        case cyan
        case blue
        case indigo
        case purple
        case pink
        case brown
        case primary
        
        var id: Theme { self }
    }
    
    @AppStorage("AppSettings.DisplayAppearance") var displayAppearance = DisplayAppearance.system
    @AppStorage("AppSettings.AccentColor") var theme = Theme.indigo
    
    let appVersion: String?
    
    init(appVersion: AppVersion = AppVersion()) {
        self.appVersion = appVersion.version()
    }
}

// MARK: - Display Appearance

extension AppSettings.DisplayAppearance {
    
    var title: Text {
        switch self {
        case .system:
            return Text("System", comment: "System Appearance automatically matches the system appearance.")
        case .light:
            return Text("Light", comment: "Light Appearance")
        case .dark:
            return Text("Dark", comment: "Dark Appearance")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - App Theme

extension AppSettings.Theme {
    
    var title: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        case .primary:
            return .primary
        }
    }
}

// MARK: - App Version

extension AppSettings {
    
    struct AppVersion {
        
        private let bundle: Bundle
        
        init(bundle: Bundle = .main) {
            self.bundle = bundle
        }
        
        func version() -> String? {
            guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                  let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else {
                return nil
            }
            
            return "\(version) (\(build))"
        }
    }
}
