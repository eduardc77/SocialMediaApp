//
//  Comparable+Extensions.swift
//  SocialMedia
//

import Foundation

public extension Comparable {
    func clamped(min minValue: Self, max maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}
