//
//  BackgroundColor.swift
//  SocialMedia
//

import SwiftUI

#if canImport(UIKit)
public extension Color {
    static let separator = Self(.separator)
    static let groupedBackground = Self(.systemGroupedBackground)
    static let secondaryGroupedBackground = Self(.secondarySystemGroupedBackground)
    static let tertiaryGroupedBackground = Self(.tertiarySystemGroupedBackground)
}

#elseif canImport(AppKit)
public extension Color {
    static let separator = Self(.separatorColor)
    static let groupedBackground = Self(.windowBackgroundColor)
    static let secondaryGroupedBackground = Self(.controlBackgroundColor)
    static let tertiaryGroupedBackground = Self(.tertiarySystemFill)
}
#endif
