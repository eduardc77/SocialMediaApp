//
//  FirestoreConstants.swift
//  SocialMedia
//

import Firebase

public struct FirestoreConstants {
    private static let Root = Firestore.firestore()
    
    public static let users = Root.collection("users")
    public static let posts = Root.collection("posts")
    public static let followers = Root.collection("followers")
    public static let following = Root.collection("following")
    public static let activity = Root.collection("activity")
    
    
    public static func replies(_ depthLevel: Int = 0) -> CollectionReference {
        depthLevel == 0 ? Root.collection("replies") : Root.collection("replies\(depthLevel)")
    }
}
