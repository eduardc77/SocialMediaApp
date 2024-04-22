//
//  ResetPasswordView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI

struct ResetPasswordView: View {
    @StateObject private var model = ResetPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Bool
    
    var body: some View {
        Form {
            Section {
                AuthTextField(type: .email, text: $model.email)
                    .focused($focusedField)
            } footer: {
                Text(model.footerText)
                    .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
                    .listRowInsets(.init(top: 10, leading: 5, bottom: 10, trailing: 0))
#endif
            }
            
            Button(AuthScreen.resetPassword.buttonTitle) {
                focusedField = false
                Task {
                    try await model.sendPasswordResetEmail()
                }
            }
            .buttonStyle(.primary(loading: model.loading))
            .disabled(!model.validForm || model.loading)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            
            .alert(isPresented: $model.showErrorAlert) {
                Alert(title: Text(AuthScreen.resetPassword.errorAlertTitle),
                      message: Text(model.authError?.description ?? ""))
            }
        }
        .formStyle(.grouped)
        .disabled(model.loading)
        .navigationTitle(AuthScreen.resetPassword.navigationTitle)
        .alert(isPresented: $model.showEmailSentAlert) {
            Alert(title: Text(model.emailSentAlertTitle),
                  message: Text(model.emailSentAlertMessage),
                  dismissButton: .default(Text("Done"), action: { dismiss() }))
        }
    }
}

#Preview {
    ResetPasswordView()
}
