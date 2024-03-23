//
//  PreferenceKeys.swift
//  SocialMedia
//

import SwiftUI

struct MinTitleHeightPreferenceKey: PreferenceKey {
    enum Metric: Equatable {
        case absolute(CGFloat)
        case unit(CGFloat)
    }
    
    static var defaultValue: Metric = .absolute(0)
    
    static func reduce(value: inout Metric, nextValue: () -> Metric) {
        let next = nextValue()
        guard next != defaultValue else { return }
        value = next
    }
}

public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        value = max(value, next)
    }
}

struct TitleHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        value = max(value, next)
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
