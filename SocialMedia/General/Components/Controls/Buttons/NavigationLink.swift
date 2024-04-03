//
//  NavigationLink.swift
//  SocialMedia
//

import SwiftUI

public struct NavigationLink<Label: View>: View {
    var label: Label
    var action: () -> Void
    
    public init(@ViewBuilder label: () -> Label, action: @escaping () -> Void) {
        self.label = label()
        self.action = action
    }
    
    public var body: some View {
        Button(action: action, label: { label })
            .buttonStyle(.borderless)
    }
}
