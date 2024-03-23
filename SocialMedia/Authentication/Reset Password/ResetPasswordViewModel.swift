//
//  ResetPasswordViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var didSendEmail = false
    @Published var isLoading: Bool = false
    
    @Published var showAlert: Bool = false
    
    var validForm: Bool {
        !email.isEmpty
        && email.contains(".")
        && email.contains("@")
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
  
    func sendPasswordResetEmail() async throws {
        isLoading = true
        try await AuthService.sendPasswordResetEmail(toEmail: email)
        isLoading = false
        didSendEmail = true
    }
}
