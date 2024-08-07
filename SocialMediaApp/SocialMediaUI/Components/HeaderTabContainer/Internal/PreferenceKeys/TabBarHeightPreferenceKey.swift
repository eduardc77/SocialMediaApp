//
//  TabBarHeightPreferenceKey.swift
//  SocialMedia
//

import SwiftUI

struct TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        value = max(value, next)
    }
}
