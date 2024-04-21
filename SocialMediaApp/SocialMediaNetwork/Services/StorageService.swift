//
//  StorageService.swift
//  SocialMedia
//

import SwiftUI
import FirebaseStorage

public struct StorageService {
    
    public enum UploadType {
        case profile(userID: String)
        case post(userID: String, postID: String)
        
        public var filePath: StorageReference {
            switch self {
            case .profile(let userID):
                return profileImageReference(userID: userID)
            case .post(let userID, let postID):
                return postReference(userID: userID, postID: postID)
            }
        }
        
        private func profileImageReference(userID: String) -> StorageReference {
            StorageService.storage.child("profile_images").child(userID)
        }
        
        private func postReference(userID: String, postID: String) -> StorageReference {
            StorageService.storage.child("post_images").child(userID).child(postID)
        }
    }
    
    private static let storage = Storage.storage().reference()
    
    public static func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    public static func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    public static func getData(userId: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
#if canImport(UIKit)
    public static func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        return image
    }
#elseif canImport(AppKit)
    
    public static func getImage(userId: String, path: String) async throws -> NSImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = NSImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        return image
    }
#endif

    public static func uploadImage(imageData: Data, type: UploadType) async throws -> String {
        do {
            let storageReference = type.filePath
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            
            let returnedMetaData = try await storageReference.putDataAsync(imageData, metadata: meta)
            
            guard let returnedPath = returnedMetaData.path else {
                throw URLError(.badServerResponse)
            }
            return try await getUrlForImage(path: returnedPath).absoluteString
            
        } catch {
            print("DEBUG: Failed to upload image \(error.localizedDescription)")
            throw URLError(.badServerResponse)
        }
    }

    public static func deleteImage(path: String) async throws {
        try await getPathForImage(path: path).delete()
    }
}
