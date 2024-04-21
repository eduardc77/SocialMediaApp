//
//  ImageSize.swift
//  SocialMedia
//

import Foundation

public enum ImageSize {
    case none
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    case custom(width: CGFloat? = nil, height: CGFloat? = nil)
    
    public var value: Size {
        switch self {
        case .none:
            return Size()
        case .xxSmall: return Size(width: 26, height: 26)
        case .xSmall: return Size(width: 32, height: 32)
        case .small: return Size(width: 40, height: 40)
        case .medium: return Size(width: 55, height: 55)
        case .large: return Size(width: 80, height: 80)
        case .xLarge: return Size(width: 100, height: 100)
        case .xxLarge: return Size(width: 140, height: 140)
        case .custom(width: let width, height: let height):
            return Size(width: width, height: height)
        }
    }
}
