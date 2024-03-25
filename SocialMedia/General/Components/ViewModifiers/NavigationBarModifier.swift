//
//  NavigationBarModifier.swift
//  SocialMedia
//

import SwiftUI

struct CustomNavigationBar: ViewModifier {
    let title: String
#if os(iOS)
    let displayMode: NavigationBarItem.TitleDisplayMode
#endif
    let background: Material
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
#if os(iOS)
            .navigationBarTitleDisplayMode(displayMode)
#endif
    }
}

extension View {
#if os(iOS)
    func navigationBar(title: String,
                       displayMode: NavigationBarItem.TitleDisplayMode = .inline,
                       background: Material = .bar) -> some View {
        modifier(CustomNavigationBar(title: title,
                                     displayMode: displayMode,
                                     background: background))
    }
#else
    func navigationBar(title: String,
                       background: Material = .bar) -> some View {
        modifier(CustomNavigationBar(title: title,
                                     background: background))
    }
#endif
}
