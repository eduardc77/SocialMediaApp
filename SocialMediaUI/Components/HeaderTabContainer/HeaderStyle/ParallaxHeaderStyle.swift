//
//  ParallaxHeaderStyle.swift
//  SocialMedia
//

import SwiftUI

/// Header elements are offset to track content scrolling, but at a slower rate to achieve a parallax effect. An optional fade parameter can be enabled for content to 
/// discreetly fade away as the sticky header scrolls out of view. This is typically applied to a resizable image in the background view.
public struct ParallaxHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {
    
    /// Constructs a parallax header style.
    /// - Parameters:
    ///   - amount: The amount of parallax. A value of 0 fixes the element on screen while a value of 1 tracks with scrolling.
    ///   - fade: If `true`, the receiving view fades out as the sticky header scrolls out of view.
    public init(amount: CGFloat = 0.35, fade: Bool = false) {
        self.amount = amount
        self.fade = fade
    }
    
    private let amount: CGFloat
    private let fade: Bool
    
    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .offset(CGSize(width: 0, height: context.offset < 0 ? 0 : context.offset * amount))
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }
}
