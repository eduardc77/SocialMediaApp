//
//  MainButtonStyle.swift
//  SocialMedia
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    var buttonWidth: CGFloat = .infinity
    var buttonHeight: CGFloat = 44
    var foregroundColor: Color = Color.secondaryGroupedBackground
    var backgroundColor: Color = .primary
    @Binding var isLoading: Bool
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
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
                if isLoading {
                    ZStack {
                        backgroundColor.clipShape(RoundedRectangle(cornerRadius: 8))
                        ProgressView().tint(foregroundColor)
                    }
                }
            }
    }
}

extension ButtonStyle where Self == MainButtonStyle {
    static var main: MainButtonStyle { MainButtonStyle(isLoading: .constant(false)) }
    
    static func main(buttonWidth: CGFloat = .infinity, buttonHeight: CGFloat = 44, foregroundColor: Color = Color.secondaryGroupedBackground, backgroundColor: Color = .primary, isLoading: Binding<Bool>) -> MainButtonStyle {
        MainButtonStyle(buttonWidth: buttonWidth, buttonHeight: buttonHeight, foregroundColor: foregroundColor, backgroundColor: backgroundColor, isLoading: isLoading)
    }
}
