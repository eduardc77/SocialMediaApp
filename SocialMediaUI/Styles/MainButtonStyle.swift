//
//  MainButtonStyle.swift
//  SocialMedia
//

import SwiftUI

public struct MainButtonStyle: ButtonStyle {
    private var buttonWidth: CGFloat
    private var buttonHeight: CGFloat
    private var foregroundColor: Color
    private var backgroundColor: Color
    private var loading: Bool
    @Environment(\.isEnabled) private var isEnabled
    
    public init(buttonWidth: CGFloat = .infinity, buttonHeight: CGFloat = 44, foregroundColor: Color = Color.secondaryGroupedBackground, backgroundColor: Color = .primary, loading: Bool) {
        self.buttonWidth = buttonWidth
        self.buttonHeight = buttonHeight
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.loading = loading
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(!configuration.isPressed ? foregroundColor : Color.secondary)
            .frame(maxWidth: buttonWidth, minHeight: buttonHeight, idealHeight: buttonHeight)
            .background(
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                if loading {
                    ZStack {
                        backgroundColor.clipShape(RoundedRectangle(cornerRadius: 8))
                        ProgressView().tint(foregroundColor)
                    }
                }
            }
    }
}

public extension ButtonStyle where Self == MainButtonStyle {
    static var main: MainButtonStyle { MainButtonStyle(loading: false) }
    
    static func main(buttonWidth: CGFloat = .infinity, buttonHeight: CGFloat = 44, foregroundColor: Color = Color.secondaryGroupedBackground, backgroundColor: Color = .primary, loading: Bool) -> MainButtonStyle {
        MainButtonStyle(buttonWidth: buttonWidth, buttonHeight: buttonHeight, foregroundColor: foregroundColor, backgroundColor: backgroundColor, loading: loading)
    }
}
