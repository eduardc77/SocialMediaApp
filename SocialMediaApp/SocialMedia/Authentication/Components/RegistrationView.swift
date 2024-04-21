//
//  RegistrationView.swift
//  SocialMedia
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @FocusState private var focusedField: RegisterField?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            textfieldsSection
            registerButton
        }
        .formStyle(.grouped)
        .disabled(viewModel.isAuthenticating)
        .navigationTitle(AuthScreen.register.navigationTitle)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(AuthScreen.register.errorAlertTitle),
                  message: Text(viewModel.authError?.description ?? ""))
        }
    }
}

// MARK: - Subviews

private extension RegistrationView {
    
    var textfieldsSection: some View {
        Section {
            AuthTextField(type: .email, text: $viewModel.user.email)
                .focused($focusedField, equals: .email)
            AuthTextField(type: .password, text: $viewModel.user.password)
                .focused($focusedField, equals: .password)
            AuthTextField(type: .name, text: $viewModel.user.fullName)
                .focused($focusedField, equals: .fullName)
            AuthTextField(type: .username, text: $viewModel.user.username)
                .focused($focusedField, equals: .username)
            
        } footer: {
            Toggle(isOn: $viewModel.isAgreementChecked) {
                Text(.init(viewModel.agreementText))
                    .multilineTextAlignment(.leading)
            }
            .toggleStyle(.checkboxStyle)
            .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
            .listRowInsets(.init(top: 10, leading: 4, bottom: 10, trailing: 0))
#endif
            .alert(isPresented: $viewModel.showAgreementAlert, content: {
                Alert(title: Text(viewModel.agreementAlertTitle), message: Text(viewModel.agreementAlertMessage), dismissButton: .cancel())
            })
        }
    }
    
    var registerButton: some View {
        Button(AuthScreen.register.buttonTitle.capitalized) {
            guard viewModel.isAgreementChecked else {
                viewModel.showAgreementAlert = true
                return
            }
            Task { try await viewModel.createUser() }
        }
        .buttonStyle(.primary(loading: viewModel.isAuthenticating))
        .disabled(!viewModel.validForm)
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }
}

// MARK: - Types

private extension RegistrationView {
    private enum RegisterField {
        case email
        case password
        case fullName
        case username
    }
}

#Preview {
    RegistrationView()
}