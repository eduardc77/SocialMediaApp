//
//  OffsetHeaderStyle.swift
//  SocialMedia
//

import SwiftUI

/// Header elements are offset to track content scrolling. An optional fade parameter can be enabled for content to discreetly fade away as the
/// sticky header scrolls out of view. This is typically applied to the title view or its elements.
public struct OffsetHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {
    
    /// Constructs an offset header style.
    /// - Parameter fade: If `true`, the receiving view fades out as the sticky header scrolls out of view.
    public init(fade: Bool = true) {
        self.fade = fade
    }
    
    private let fade: Bool
    
    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }
}
