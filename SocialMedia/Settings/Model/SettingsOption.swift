//
//  SettingsOption.swift
//  SocialMedia
//

import Foundation

enum SettingsOption: String {
    case appColor = "App Color"
    case displayAppearance = "Display Appearance"
    case about
    case rate
    case feedback
    case follow
    case termsOfUse = "Terms of Use"
    case privacyPolicy = "Privacy Policy"
    case logout
}

extension SettingsOption {
    var icon: String {
        switch self {
        case .appColor:
            return "paintpalette.fill"
        case .displayAppearance:
            return "moonphase.first.quarter.inverse"
        case .about:
            return "info.circle.fill"
        case .rate:
            return "star.fill"
        case .feedback:
            return "paperplane.fill"
        case .follow:
            return "person.2.fill"
        case .termsOfUse:
            return "doc.text.fill"
        case .privacyPolicy:
            return "lock.doc.fill"
        case .logout:
            return "rectangle.portrait.and.arrow.forward.fill"
        }
    }
}
