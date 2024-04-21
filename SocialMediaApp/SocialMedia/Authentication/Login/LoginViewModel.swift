//
//  LoginViewModel.swift
//  SocialMedia
//

import FirebaseAuth
import SocialMediaNetwork

final class LoginViewModel: ObservableObject {
    @Published var user = UserInputData()
    @Published var loading = false
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
