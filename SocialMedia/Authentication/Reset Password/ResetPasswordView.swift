//
//  ResetPasswordView.swift
//  SocialMedia
//

import SwiftUI

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
                    .listRowInsets(.init(top: 10, leading: 5, bottom: 10, trailing: 5))
            }

            Button(AuthScreen.resetPassword.buttonTitle) {
                focusedField = false
                Task { 
                    try await viewModel.sendPasswordResetEmail()
                    viewModel.showAlert = true
                }
            }
            .buttonStyle(.main(isLoading: $viewModel.isLoading))
            .disabled(!viewModel.validForm)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
        }
        .navigationTitle(AuthScreen.resetPassword.navigationTitle)
        .alert(isPresented: $viewModel.didSendEmail) {
            Alert(title: Text(viewModel.emailSentAlertTitle),
                  message: Text(viewModel.emailSentAlertMessage),
                  dismissButton: .default(Text("Done"), action: { dismiss() }))
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
