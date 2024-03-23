//
//  LoginView.swift
//  SocialMedia
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @FocusState private var focusedField: LoginField?
    
    var body: some View {
        NavigationStack {
            Form {
                logoImage
                textfieldsSection
                loginButton
            }
            .navigationTitle(AuthScreen.login.navigationTitle)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.authError?.description ?? ""))
            }
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    var logoImage: some View {
        Section {
            Image(systemName: "questionmark.app.fill")
                .resizable()
                .frame(width: 66, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }
    
    var textfieldsSection: some View {
        Section {
            AuthTextField(type: .email, text: $viewModel.user.email)
                .focused($focusedField, equals: .email)
            AuthTextField(type: .password, text: $viewModel.user.password)
                .focused($focusedField, equals: .password)
        } footer: {
            HStack {
                NavigationLink(AuthScreen.resetPassword.buttonTitle) {
                    ResetPasswordView()
                }
                Spacer()
                NavigationLink(AuthScreen.register.buttonTitle) {
                    RegistrationView()
                }
            }
            .listRowInsets(.init(top: 10, leading: 5, bottom: 10, trailing: 5))
        }
    }
    
    var loginButton: some View {
        Button {
            Task { try await viewModel.login() }
        } label: {
            Text("Login")
        }
        .buttonStyle(.main(isLoading: $viewModel.isAuthenticating))
        .disabled(viewModel.isAuthenticating || !viewModel.validForm)
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
