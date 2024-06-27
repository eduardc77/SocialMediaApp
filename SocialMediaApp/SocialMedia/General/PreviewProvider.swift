//
//  PreviewProvider.swift
//  SocialMedia
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SocialMediaNetwork

class Preview {
    static let shared = Preview()
    
    static var user = User(
        email: "john.appleseed@icloud.com",
        username: "john_appleseed",
        fullName: "John Appleseed",
        joinDate: Timestamp(),
        profileImageURL: ""
    )
    
    static var user2 = User(
        email: "steve.jobs@icloud.com",
        username: "steve_jobs",
        fullName: "Steve Jobs",
        joinDate: Timestamp(),
        profileImageURL: ""
    )
    
    static var post = Post(
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
    
    static var post2 = Post(
        caption: "I’m as proud of many of the things we haven’t done as the things we have done. Innovation is saying no to a thousand things.",
        ownerUID: UUID().uuidString,
        category: .beauty,
        timestamp: Timestamp(),
        likes: 117,
        replies: 69,
        imageUrl: "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png",
        
        user: User(
            email: "john.appleseed@icloud.com",
            username: "john.appleseed",
            fullName: "John Appleseed",
            joinDate: Timestamp()
        )
    )
    
    static var reply = Reply(
        caption: "Great things in business are never done by one person. They're done by a team of people.",
        ownerUID: UUID().uuidString,
        replyID: UUID().uuidString,
        timestamp: Timestamp(),
        postID: UUID().uuidString,
        postOwnerUID: UUID().uuidString,
        likes: 18,
        reposts: 5,
        replies: 7,
        imageUrl:  "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png",
        post: post,
        user: user)
    
    static var reply2 = Reply(
        caption: "Design is a funny word. Some people think design means how it looks. But of course, if you dig deeper, it's really how it works.",
        ownerUID: UUID().uuidString,
        replyID: UUID().uuidString,
        timestamp: Timestamp(),
        postID: UUID().uuidString,
        postOwnerUID: UUID().uuidString,
        likes: 18,
        reposts: 5,
        replies: 7,
        imageUrl:  "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png",
        post: post2,
        user: user)
    
    static var activityModel = Activity(
        type: ActivityType.like,
        senderUID: UUID().uuidString,
        timestamp: Timestamp(),
        user: user
    )
}
