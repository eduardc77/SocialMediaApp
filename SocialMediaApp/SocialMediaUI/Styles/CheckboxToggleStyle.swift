//
//  CheckboxToggleStyle.swift
//  SocialMedia
//

import SwiftUI

public struct CheckboxToggleStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack(alignment: .center) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(.tint)
                configuration.label
                    .foregroundStyle(Color.primary)
            }
        })
        .buttonStyle(.borderless)
    }
}

public extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkboxStyle: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview {
    struct Example: View {
        @State private var isOn: Bool = false
        private var agreementText: String = "I agree to the terms and conditions."
        
        var body: some View {
            Toggle(isOn: $isOn) {
                Text(agreementText)
            }
            .toggleStyle(.checkboxStyle)
        }
    }
    
    return Example()
}
