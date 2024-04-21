//
//  SecondaryButtonStyle.swift
//  SocialMedia
//

import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
    var buttonWidth: CGFloat? = .infinity
    var buttonHeight: CGFloat = 32
    var foregroundColor: Color = Color.primary
    var activeBackgroundColor: Color = .tertiaryGroupedBackground
    var inactiveBackgroundColor: Color = Color.gray
    var loading: Bool = false
    var isActive: Bool = false
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(isActive ? foregroundColor : Color.accentColor)
            .frame(maxWidth: buttonWidth, minHeight: buttonHeight, idealHeight: buttonHeight)
            .padding(.horizontal)
            .background(.fill.secondary, in: .rect(cornerRadius: 8))
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                if loading {
                    ZStack {
                        inactiveBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 8))
                        ProgressView()
                    }
                }
            }
    }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle(loading: false, isActive: false) }
    
    static func secondary(buttonWidth: CGFloat? = .infinity, buttonHeight: CGFloat = 32, foregroundColor: Color = Color.primary, activeBackgroundColor: Color = .tertiaryGroupedBackground, inactiveBackgroundColor: Color = Color.gray, loading: Bool = false, isActive: Bool = true) -> SecondaryButtonStyle {
        SecondaryButtonStyle(buttonWidth: buttonWidth, buttonHeight: buttonHeight, foregroundColor: foregroundColor, activeBackgroundColor: activeBackgroundColor, inactiveBackgroundColor: inactiveBackgroundColor, loading: loading, isActive: isActive)
    }
}
