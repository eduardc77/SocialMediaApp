//
//  RegistrationView.swift
//  SocialMedia
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var model = RegistrationViewModel()
    @FocusState private var focusedField: RegisterField?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            textfieldsSection
            registerButton
        }
        .formStyle(.grouped)
        .disabled(model.loading)
        .navigationTitle(AuthScreen.register.navigationTitle)
        .alert(isPresented: $model.showAlert) {
            Alert(title: Text(AuthScreen.register.errorAlertTitle),
                  message: Text(model.authError?.description ?? ""))
        }
    }
}

// MARK: - Subviews

private extension RegistrationView {
    
    var textfieldsSection: some View {
        Section {
            AuthTextField(type: .email, text: $model.user.email)
                .focused($focusedField, equals: .email)
            AuthTextField(type: .password, text: $model.user.password)
                .focused($focusedField, equals: .password)
            AuthTextField(type: .name, text: $model.user.fullName)
                .focused($focusedField, equals: .fullName)
            AuthTextField(type: .username, text: $model.user.username)
                .focused($focusedField, equals: .username)
            
        } footer: {
            Toggle(isOn: $model.isAgreementChecked) {
                Text(.init(model.agreementText))
                    .multilineTextAlignment(.leading)
            }
            .toggleStyle(.checkboxStyle)
            .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
            .listRowInsets(.init(top: 10, leading: 5, bottom: 10, trailing: 0))
#endif
            .alert(isPresented: $model.showAgreementAlert, content: {
                Alert(title: Text(model.agreementAlertTitle), message: Text(model.agreementAlertMessage), dismissButton: .cancel())
            })
        }
    }
    
    var registerButton: some View {
        Button(AuthScreen.register.buttonTitle.capitalized) {
            guard model.isAgreementChecked else {
                model.showAgreementAlert = true
                return
            }
            Task { try await model.createUser() }
        }
        .buttonStyle(.primary(loading: model.loading))
        .disabled(!model.validForm || model.loading)
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
