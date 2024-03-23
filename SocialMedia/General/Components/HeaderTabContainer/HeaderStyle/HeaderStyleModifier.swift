//
//  HeaderStyleModifier.swift
//  SocialMedia
//

import SwiftUI

public extension View {
    
    // A view modifier that may be applied to sticky header elements to easily create sticky header effects,
    // such as fade, shrink and parallax. The modifier may be applied to multiple elements separately or even multiple
    // times on the same element to combine effects.
    func headerStyle<S, Tab>(
        _ style: S,
        context: HeaderContext<Tab>
    ) -> some View where Tab: Hashable, S: HeaderStyle, S.Tab == Tab {
        modifier(HeaderStyleModifier(style: style, context: context))
    }
}

struct HeaderStyleModifier<S, Tab>: ViewModifier where Tab: Hashable, S: HeaderStyle, S.Tab == Tab {
    
    let style: S
    let context: HeaderContext<Tab>
    
    func body(content: Content) -> some View {
        style.makeBody(context: context, content: AnyView(content))
    }
}
