//
//  NavigationBarModifier.swift
//  SocialMedia
//

import SwiftUI

struct CustomNavigationBar: ViewModifier {
    let title: String
    let displayMode: NavigationBarItem.TitleDisplayMode
    let background: Material
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
    }
}

extension View {
    func navigationBar(title: String,
                       displayMode: NavigationBarItem.TitleDisplayMode = .inline,
                       background: Material = .bar) -> some View {
        modifier(CustomNavigationBar(title: title,
                                     displayMode: displayMode,
                                     background: background))
    }
}
