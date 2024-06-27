//
//  AuthServiceable.swift
//  SocialMedia
//

import FirebaseAuth

protocol AuthServiceable {
    var userSession: FirebaseAuth.User? { get }
    
    func login(withUser user: UserInputData) async throws
    func registerUser(withData userInputData: UserInputData) async throws
    func signOut()
    static func sendPasswordResetEmail(toEmail email: String) async throws
}
