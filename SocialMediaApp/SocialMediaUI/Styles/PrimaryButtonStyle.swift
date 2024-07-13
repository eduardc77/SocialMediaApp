//
//  PrimaryButtonStyle.swift
//  SocialMedia
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    var buttonWidth: CGFloat = .infinity
    var buttonHeight: CGFloat  = 40
    var foregroundColor: Color = Color.white
    var backgroundColor: Color = Color.accentColor
    var loading: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .opacity(!loading ? 1 : 0)
            .frame(maxWidth: buttonWidth, minHeight: buttonHeight, idealHeight: buttonHeight)
            .background(backgroundColor, in: .rect(cornerRadius: 8))
            .opacity(!configuration.isPressed ? 1 : 0.5)
            .overlay {
                if loading {
                    ProgressView()
                }
            }
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle(loading: false) }
    
    static func primary(buttonWidth: CGFloat = .infinity, buttonHeight: CGFloat = 40, foregroundColor: Color = Color.white, backgroundColor: Color = Color.accentColor, loading: Bool = false) -> PrimaryButtonStyle {
        PrimaryButtonStyle(buttonWidth: buttonWidth, buttonHeight: buttonHeight, foregroundColor: foregroundColor, backgroundColor: backgroundColor, loading: loading)
    }
}

#Preview {
    VStack {
        Button("Done") {}
            .buttonStyle(.primary)
        Button("Cancel") {}
            .buttonStyle(.primary(backgroundColor: .red))
    }
    .padding()
}
