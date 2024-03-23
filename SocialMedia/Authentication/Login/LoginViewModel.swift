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
        && user.email.contains(".")
        && user.email.contains("@")
        && !user.password.isEmpty
    }
    
    @MainActor
    func login() async throws {
        do {
            isAuthenticating = true
            try await AuthService.shared.login(withUser: user)
            isAuthenticating = false
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            showAlert = true
            isAuthenticating = false
        }
    }
}
