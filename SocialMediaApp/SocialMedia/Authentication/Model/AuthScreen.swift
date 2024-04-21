//
//  AuthScreen.swift
//  SocialMedia
//

enum AuthScreen: String {
    case login, register, resetPassword
    
    var buttonTitle: String {
        switch self {
        case .resetPassword:
            return "Reset Password"
        default:
            return self.rawValue.capitalized
        }
    }

    var navigationTitle: String {
        switch self {
        case .login:
            return "Login"
        case .register:
            return "Register"
        case .resetPassword:
            return "Reset Password"
        }
    }
    
    var errorAlertTitle: String {
        switch self {
        case .resetPassword:
            return "Reset Password Error"
        default:
            return "\(self.rawValue.capitalized) Error"
        }
    }
}
