//
//  AnyTransition.swift
//  SocialMedia
//

import SwiftUI

extension AnyTransition {
    static var noTransition: AnyTransition {
        .asymmetric(insertion: .scale(scale: 1), removal: .scale(scale: 0.999999))
    }
}
