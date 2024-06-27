//
//  LoginViewModel.swift
//  SocialMedia
//

import Observation
import FirebaseAuth
import SocialMediaNetwork

@Observable final class LoginViewModel {
    var user = UserInputData()
    var loading = false
    var showAlert = false
    var authError: AuthError?
    
    var validForm: Bool {
        !user.email.isEmpty
        && !user.password.isEmpty
        && user.email.validEmail
    }
    
    @MainActor
    func login() async throws {
        do {
            loading = true
            try await AuthService.shared.login(withUser: user)
            loading = false
        } catch {
            authError = AuthError(error: error)
            showAlert = true
            loading = false
        }
    }
}
