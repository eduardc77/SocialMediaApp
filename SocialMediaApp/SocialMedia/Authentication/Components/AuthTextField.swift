//
//  AuthTextField.swift
//  SocialMedia
//

import SwiftUI

enum TextFieldType: String {
    case email
    case password
    case name
    case username
}

struct AuthTextField: View {
    let type: TextFieldType
    @State var isSecure: Bool = false
    @Binding var text: String
    
    var body: some View {
        HStack {
            if !isSecure {
                TextField(type.rawValue.capitalized, text: $text)
#if !os(macOS)
                    .keyboardType(type == .email ? .emailAddress : .default)
                    .textInputAutocapitalization(type == .name ? .words : .never)
#endif
            } else {
                SecureField(type.rawValue.capitalized, text: $text)
            }
            
            if type == .password {
                Button {
                    self.isSecure.toggle()
                } label: {
                    Image(systemName: self.isSecure ? "eye.slash" : "eye")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onFirstAppear {
            if type == .password {
                isSecure = true
            }
        }
    }
}
