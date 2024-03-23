//
//  BinaryFloatingPoint+Extensions.swift
//  SocialMedia
//

public extension BinaryFloatingPoint {
    func clamped01() -> Self {
        return self.clamped(min: 0, max: 1)
    }
}
