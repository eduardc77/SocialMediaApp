//
//  MinTitleHeightPreferenceKey.swift
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
