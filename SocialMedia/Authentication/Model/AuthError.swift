//
//  AuthError.swift
//  SocialMedia
//

import Firebase

enum AuthError: Error {
    case invalidEmail
    case emailAlreadyInUse
    case invalidPassword
    case userNotFound
    case usernameAlreadyInUse
    case weakPassword
    case unknown
    
    init(authErrorCode: AuthErrorCode.Code) {
        switch authErrorCode {
            case .invalidEmail:
                self = .invalidEmail
            case .emailAlreadyInUse:
                self = .emailAlreadyInUse
            case .wrongPassword:
                self = .invalidPassword
            case .weakPassword:
                self = .weakPassword
            case .userNotFound:
                self = .userNotFound
            case .credentialAlreadyInUse:
                self = .usernameAlreadyInUse
            default:
                self = .unknown
        }
    }
    
    var description: String {
        switch self {
            case .invalidEmail:
                return "The email you entered is invalid. Please try again"
            case .emailAlreadyInUse:
                return "The email address is already in use by another account."
            case .invalidPassword:
                return "Incorrect password. Please try again"
            case .userNotFound:
                return "It looks like there is no account associated with this email. Create an account to continue"
            case .usernameAlreadyInUse:
                return "The username is already in use by another account. Please try another."
            case .weakPassword:
                return "Your password must be at least 6 characters in length. Please try again."
            case .unknown:
                return "An unknown error occurred. Please try again."
        }
    }
}
