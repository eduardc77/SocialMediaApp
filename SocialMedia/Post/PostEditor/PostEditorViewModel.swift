//
//  PostEditorViewModel.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI
import SocialMediaUI
import SocialMediaNetwork
import Firebase

final class PostEditorViewModel: ObservableObject {
    @Published var caption = ""
    @Published var categorySelected: Bool = false
    
    var postCategories = PostCategory.allCases
    
    @Published var category: PostCategory = .affirmations {
        didSet {
            categorySelected = true
        }
    }
    
    var user: SocialMediaNetwork.User? {
        return UserService.shared.currentUser
    }
    
    var pickerTitle: String {
        !categorySelected ? "Category" : category.icon + " " + category.rawValue.capitalized
    }
    
    @Published var imageState: ImageData.ImageState = .empty

    func uploadPost() async throws {
        guard let userID = user?.id else { return }
     
        var post = Post(
            caption: caption,
            ownerUID: userID,
            category: category,
            timestamp: Timestamp(),
            likes: 0,
            replies: 0,
            replyDepthLevel: 0
        )
        if case let .success(postImageData) = imageState {
            post.imageUrl = try await StorageService.uploadImage(imageData: postImageData, type: .post(userID: userID, postID: post.id ?? UUID().uuidString))
        }
        try await PostService.uploadPost(post)
    }
}

