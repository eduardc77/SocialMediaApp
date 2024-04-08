//
//  SecondaryButtonStyle.swift
//  SocialMedia
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    let buttonWidth: CGFloat?
    let buttonHeight: CGFloat
    let foregroundColor: Color
    let activeBackgroundColor: Color
    let inactiveBackgroundColor: Color
    var isLoading: Bool
    var isActive: Bool
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(!configuration.isPressed ? foregroundColor : Color.secondary)
            .frame(maxWidth: buttonWidth, minHeight: buttonHeight, idealHeight: buttonHeight)
            .padding(.horizontal)
            .background(
                (configuration.isPressed || isActive ? activeBackgroundColor : inactiveBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                if isLoading {
                    ZStack {
                        inactiveBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 8)).zIndex(1)
                        ProgressView().tint(Color.secondaryGroupedBackground).zIndex(2)
                    }
                }
            }
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static func secondary(buttonWidth: CGFloat? = .infinity, buttonHeight: CGFloat = 32, foregroundColor: Color = Color.secondaryGroupedBackground, activeBackgroundColor: Color = .groupedBackground, inactiveBackgroundColor: Color = Color.primary, isLoading: Bool = false, isActive: Bool = true) -> SecondaryButtonStyle {
        SecondaryButtonStyle(buttonWidth: buttonWidth, buttonHeight: buttonHeight, foregroundColor: foregroundColor, activeBackgroundColor: activeBackgroundColor, inactiveBackgroundColor: inactiveBackgroundColor, isLoading: isLoading, isActive: isActive)
    }
}
