//
//  ResetPasswordViewModel.swift
//  SocialMedia
//

import FirebaseAuth
import SocialMediaNetwork

@MainActor
final class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading: Bool = false
    
    @Published var showEmailSentAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    
    @Published var authError: AuthError?
    
    var validForm: Bool {
        !email.isEmpty
        && email.validEmail
    }
    
    var footerText: String {
        "Enter the email you use to sign in to receive instructions for resetting your password."
    }
    
    var emailSentAlertTitle: String {
        "Password Reset Email Sent"
    }
    
    var emailSentAlertMessage: String {
        "An email has been sent to your email address \(email). Follow the directions in the email to reset your password."
    }
    
    @MainActor
    func sendPasswordResetEmail() async throws {
        isLoading = true
        do {
            try await AuthService.sendPasswordResetEmail(toEmail: email)
            isLoading = false
            showEmailSentAlert = true
        } catch {
            authError = AuthError(error: error)
            showErrorAlert = true
            isLoading = false
        }
    }
}
