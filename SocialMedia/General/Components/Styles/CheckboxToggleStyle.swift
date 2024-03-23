//
//  CheckboxToggleStyle.swift
//  SocialMedia
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(.tint)
                configuration.label
            }
        })
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
   static var checkboxStyle: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview {
    CheckboxToggleStyle_Preview()
}

private struct CheckboxToggleStyle_Preview: View {
    @State private var isOn: Bool = false
    private var agreementText: String = "I agree to the terms and conditions."

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(agreementText)
        }
        .toggleStyle(.checkboxStyle)
    }
}
