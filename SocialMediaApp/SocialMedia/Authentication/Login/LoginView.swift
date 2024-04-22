//
//  LoginView.swift
//  SocialMedia
//

import SwiftUI

struct LoginView: View {
    @StateObject private var model = LoginViewModel()
    @FocusState private var focusedField: LoginField?
    
    var body: some View {
        NavigationStack {
            Form {
                logoImage
                textfieldsSection
                loginButton
            }
            .formStyle(.grouped)
            .disabled(model.loading)
            .navigationTitle(AuthScreen.login.navigationTitle)
            .alert(isPresented: $model.showAlert) {
                Alert(title: Text(AuthScreen.login.errorAlertTitle),
                      message: Text(model.authError?.description ?? ""))
            }
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    
    var logoImage: some View {
        Section {
            Image(systemName: "shareplay")
                .foregroundStyle(.white)
                .colorMultiply(.white)
                .font(.system(size: 36))
                .padding(.vertical)
                .padding(.horizontal, 4)
                .background(.tint.secondary, in: .rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }
    
    var textfieldsSection: some View {
        Section {
            AuthTextField(type: .email, text: $model.user.email)
                .focused($focusedField, equals: .email)
            AuthTextField(type: .password, text: $model.user.password)
                .focused($focusedField, equals: .password)
        } footer: {
            HStack {
                NavigationLink(AuthScreen.register.buttonTitle) {
                    RegistrationView()
                }
                Spacer()
                NavigationLink(AuthScreen.resetPassword.buttonTitle) {
                    ResetPasswordView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
            .listRowInsets(.init(top: 10, leading: 5, bottom: 10, trailing: 5))
#endif
        }
    }
    
    var loginButton: some View {
        Button(AuthScreen.login.buttonTitle) {
            Task { try await model.login() }
        }
        .buttonStyle(.primary(loading: model.loading))
        .disabled(!model.validForm || model.loading)
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }
}

// MARK: - Types

private extension LoginView {
    enum LoginField {
        case email
        case password
    }
}

#Preview {
    LoginView()
}
