//
//  AuthService.swift
//  SocialMedia
//

import Firebase

public class AuthService: AuthServiceable {
    @Published public var userSession: FirebaseAuth.User?
    
    public static let shared = AuthService()
    
    public init() {
        self.userSession = Auth.auth().currentUser
        Task { try await UserService.shared.fetchCurrentUser() }
    }
    
    @MainActor
    public func login(withUser user: UserInputData) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: user.email, password: user.password)
            self.userSession = result.user
            try await UserService.shared.fetchCurrentUser()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    public func registerUser(withData userInputData: UserInputData) async throws {
        do {
            guard try await AuthService.isUsernameAvailable(username: userInputData.username) else {
                throw AuthErrorCode(.credentialAlreadyInUse)
            }
            let result = try await Auth.auth().createUser(withEmail: userInputData.email, password: userInputData.password)
            self.userSession = result.user
            try await AuthService.uploadUserData(userInputData, userId: result.user.uid)
        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    public func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserService.shared.resetUser()
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    public static func sendPasswordResetEmail(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send password reset email with error \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Private Properties

public extension AuthService {
    
    @MainActor
     private static func uploadUserData(_ userData: UserInputData, userId: String) async throws {
        let user = User(id: userId, email: userData.email, username: userData.username.lowercased(), fullName: userData.fullName, joinDate: Timestamp())
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await FirestoreConstants.users.document(userId).setData(encodedUser)
        UserService.shared.currentUser = user
    }
    
    static func isUsernameAvailable(username: String) async throws -> Bool {
        do {
            let querySnapshot = try await FirestoreConstants.users.whereField("username", isEqualTo: username).getDocuments()
            if querySnapshot.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            print("DEBUG: Failed to fetch users for checking 'isUsernameAvailable' with error: \(error.localizedDescription)")
            throw error
        }
    }
}
