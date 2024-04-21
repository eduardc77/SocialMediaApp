//
//  LoginViewModel.swift
//  SocialMedia
//

import FirebaseAuth
import SocialMediaNetwork

final class LoginViewModel: ObservableObject {
    @Published var user = UserInputData()
    @Published var isAuthenticating = false
    @Published var showAlert = false
    @Published var authError: AuthError?
    
    var validForm: Bool {
        !user.email.isEmpty
        && !user.password.isEmpty
        && user.email.validEmail
    }
    
    @MainActor
    func login() async throws {
        do {
            isAuthenticating = true
            try await AuthService.shared.login(withUser: user)
            isAuthenticating = false
        } catch {
            authError = AuthError(error: error)
            showAlert = true
            isAuthenticating = false
        }
    }
}
