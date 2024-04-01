//
//  AuthError.swift
//  SocialMedia
//

import Firebase

enum AuthError: Error {
    case invalidCredential
    case invalidEmail
    case emailAlreadyInUse
    case invalidPassword
    case userNotFound
    case usernameAlreadyInUse
    case weakPassword
    case other(errorText: String)
    
    init(error: Error) {
        let authErrorCode = AuthErrorCode.Code(rawValue: (error as NSError).code)
        
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
        case .invalidCredential:
            self = .invalidCredential
        default:
            self = .other(errorText: error.localizedDescription)
        }
    }
    
    var description: String {
        switch self {
        case .invalidCredential:
            return "The credentials you entered no not match our records. Please try again"
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
        case .other(let errorText):
            return errorText
        }
    }
}
