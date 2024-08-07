//
//  TabsScrollContext.swift
//  SocialMedia
//

import Foundation

public struct TabsScrollContext<Tab> where Tab: Hashable {
    /// The header context
    public var headerContext: TabsHeaderContext<Tab>

    /// The total safe height available to the scroll view
    public var safeHeight: CGFloat

    /// The total safe height available for content below the header view
    public var safeContentHeight: CGFloat {
        safeHeight - headerContext.height
    }

    public init(headerContext: TabsHeaderContext<Tab>, safeHeight: CGFloat) {
        self.headerContext = headerContext
        self.safeHeight = safeHeight
    }
}
