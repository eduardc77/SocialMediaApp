//
//  OnFirstAppearViewModifier.swift
//  SocialMedia
//

import SwiftUI

public struct OnFirstAppearModifier: ViewModifier {
    private let action: (() -> Void)?
    @State private var isFirstAppear = true
    
    public init(action: (() -> Void)?) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                if isFirstAppear {
                    action?()
                    isFirstAppear = false
                }
            }
    }
}

public extension View {
    func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(OnFirstAppearModifier(action: action))
    }
}
