//
//  RegistrationViewModel.swift
//  SocialMedia
//

import FirebaseAuth
import SocialMediaNetwork

final class RegistrationViewModel: ObservableObject {
    @Published var user = UserInputData()
    @Published var isAuthenticating = false
    @Published var showAlert = false
    @Published var authError: AuthError?
    
    @Published var isAgreementChecked: Bool = false
    @Published var showAgreementAlert: Bool = false
    
    var agreementText: String {
        "I agree to [Terms & Conditions](https://www.apple.com) and [Privacy Policy](https://www.apple.com)."
    }
    
    var agreementAlertTitle: String {
        "Terms and Conditions"
    }
    
    var agreementAlertMessage: String {
        "You must agree to the Terms and Conditions to register."
    }
    
    var validForm: Bool {
        !user.email.isEmpty
        && user.email.validEmail
        && !user.password.isEmpty
        && !user.fullName.isEmpty
        && user.password.count > 5
    }
    
    @MainActor
    func createUser() async throws {
        isAuthenticating = true
        do {
            try await AuthService.shared.registerUser(withData: user)
            isAuthenticating = false
        } catch {
            authError = AuthError(error: error)
            showAlert = true
            isAuthenticating = false
        }
    }
}
