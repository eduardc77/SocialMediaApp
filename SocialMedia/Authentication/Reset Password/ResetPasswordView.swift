//
//  ResetPasswordView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI

struct ResetPasswordView: View {
    @StateObject var viewModel = ResetPasswordViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Bool
    
    var body: some View {
        Form {
            Section {
                AuthTextField(type: .email, text: $viewModel.email)
                    .focused($focusedField)
            } footer: {
                Text(viewModel.footerText)
                    .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
                    .listRowInsets(.init(top: 10, leading: 4, bottom: 10, trailing: 0))
#endif
            }
            
            Button(AuthScreen.resetPassword.buttonTitle) {
                focusedField = false
                Task {
                    try await viewModel.sendPasswordResetEmail() 
                }
            }
            .buttonStyle(.main(isLoading: $viewModel.isLoading))
            .disabled(!viewModel.validForm)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text(AuthScreen.resetPassword.errorAlertTitle),
                      message: Text(viewModel.authError?.description ?? ""))
            }
        }
        .formStyle(.grouped)
        .disabled(viewModel.isLoading)
        .navigationTitle(AuthScreen.resetPassword.navigationTitle)
        .alert(isPresented: $viewModel.showEmailSentAlert) {
            Alert(title: Text(viewModel.emailSentAlertTitle),
                  message: Text(viewModel.emailSentAlertMessage),
                  dismissButton: .default(Text("Done"), action: { dismiss() }))
        }
    }
}

#Preview {
    ResetPasswordView()
}
