//
//  AppSettings.swift
//  SocialMedia
//

import SwiftUI

final class AppSettings: ObservableObject {
    @AppStorage("AppSettings.DisplayAppearance") var displayAppearance = DisplayAppearance.system
    @AppStorage("AppSettings.AccentColor") var theme = Theme.indigo
    
    enum DisplayAppearance: String, CaseIterable {
        case system
        case light
        case dark
    }
    
    enum Theme: String, CaseIterable {
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
