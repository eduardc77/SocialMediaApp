//
//  NavigationBarModifier.swift
//  SocialMedia
//

import SwiftUI

public struct CustomNavigationBar: ViewModifier {
    private let title: String
#if os(iOS)
    private let displayMode: NavigationBarItem.TitleDisplayMode
#endif
    private let background: Material
    
    public init(title: String, displayMode: NavigationBarItem.TitleDisplayMode = .inline, background: Material = .bar) {
        self.title = title
        self.displayMode = displayMode
        self.background = background
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationTitle(title)
#if os(iOS)
            .navigationBarTitleDisplayMode(displayMode)
#endif
    }
}

public extension View {
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
