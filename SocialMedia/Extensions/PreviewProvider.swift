//
//  PreviewProvider.swift
//  SocialMedia
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SocialMediaNetwork

extension PreviewProvider {
    static var preview: Preview {
        return Preview.shared
    }
}

class Preview {
    static let shared = Preview()
    
    var post = Post(
        caption: "Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work. And the only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle. As with all matters of the heart, you'll know when you find it.",
        ownerUID: UUID().uuidString,
        category: .productivity,
        timestamp: Timestamp(),
        likes: 117,
        replies: 69,
        imageUrl: "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png",
        
        user: User(
            email: "stevejobs@icloud.com",
            username: "steve_jobs",
            fullName: "Steve Jobs",
            joinDate: Timestamp()
        )
    )
    
    var user = User(
        email: "john.appleseed@icloud.com",
        username: "john_appleseed",
        fullName: "John Appleseed",
        joinDate: Timestamp(),
        profileImageURL: ""
    )
    
    lazy var activityModel = Activity(
        type: ActivityType.like,
        senderUID: UUID().uuidString,
        timestamp: Timestamp(),
        user: self.user
    )
    
    lazy var reply = Reply(
        postID: UUID().uuidString,
        replyID: UUID().uuidString,
        replyText: "Great things in business are never done by one person. They're done by a team of people.",
        ownerUID: UUID().uuidString,
        postOwnerUID: UUID().uuidString,
        timestamp: Timestamp(),
        likes: 18,
        reposts: 5,
        replies: 7,
        imageUrl:  "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png",
        didLike: false,
        didRepost: false,
        didSave: false,
        post: post,
        replyUser: user)
}
