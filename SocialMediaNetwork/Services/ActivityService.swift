//
//  ActivityService.swift
//  SocialMedia
//

import Firebase
import FirebaseFirestoreSwift

public struct ActivityService {
    public static func fetchUserActivity() async throws -> [Activity] {
        guard let currentUID = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await FirestoreConstants
            .activity
            .document(currentUID)
            .collection("userNotifications")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Activity.self) })
    }
    
    public static func uploadNotification(toUID uid: String, type: ActivityType, postID: String? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUID else { return }
        
        let model = Activity(
            type: type,
            senderUID: currentUID,
            timestamp: Timestamp(),
            postID: postID
        )
        
        guard let data = try? Firestore.Encoder().encode(model) else { return }
        
        FirestoreConstants.activity.document(uid).collection("userNotifications").addDocument(data: data)
    }
    
    public static func deleteNotification(toUID uid: String, type: ActivityType, postID: String? = nil) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await FirestoreConstants
            .activity
            .document(uid)
            .collection("userNotifications")
            .whereField("id", isEqualTo: currentUID)
            .getDocuments()
        
        for document in snapshot.documents {
            let notification = try? document.data(as: Activity.self)
            guard notification?.type == type else { return }
            
            if postID != nil {
                guard postID == notification?.postID else { return }
            }
            
            try await document.reference.delete()
        }
    }
}
