//
//  PostButtonGroupView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

class TempPost: ObservableObject {
    @Published var didLike: Bool = false
    @Published var didSave: Bool = false
}

struct PostButtonGroupView: View {
    var model: PostButtonGroupViewModel
    var onReplyTapped: (PostType) -> Void
    
    @StateObject var post = TempPost()
 
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PostButtonType.allCases) { buttonType in
                switch buttonType {
                case .like:
                    PostButton(count: model.numberOfLikes,
                               isActive: post.didLike,
                               buttonType: buttonType) {
                        Task {
                            try await likeButtonTapped()
                        }
                    }
                    Divider().padding(.vertical, 5)
                    
                case .reply:
                    PostButton(count: model.numberOfReplies,
                               isActive: false,
                               buttonType: buttonType) {
                        onReplyTapped(model.postType)
                    }
                    Divider().padding(.vertical, 5)
                    
                case .repost:
                    PostButton(count: model.numberOfReposts,
                               isActive: false,
                               buttonType: buttonType) {
                        if model.temporaryRepostCount == 0 {
                            model.temporaryRepostCount += 1
                        } else {
                            model.temporaryRepostCount -= 1
                        }
                    }
                    Divider().padding(.vertical, 5)
                    
                case .save:
                    PostButton(count: post.didSave ? 1 : 0,
                               isActive: post.didSave,
                               buttonType: buttonType) {
                        Task {
                            try await saveButtonTapped()
                        }
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: model.postType, { _, _ in
            Task {
                await checkForUserActivity()
            }
        })
        .task {
            await checkForUserActivity()
        }
    }
    
    func likeButtonTapped() async throws {
        if post.didLike {
            post.didLike = false
            try await model.unlikePost()
           
        } else {
            post.didLike = true
            try await model.likePost()
           
        }
    }
    
    func saveButtonTapped() async throws {
        if post.didSave {
            post.didSave = false
            try await model.unsavePost()
           
        } else {
            post.didSave = true
            try await model.savePost()
        }
    }
    
    func checkIfUserLikedPost() async throws {
        switch model.postType {
        case .post(let post):
            if try await model.didUserLike(post: post) {
                self.post.didLike = true
            } else {
                self.post.didLike = false
            }
        case .reply(let reply):
            if try await model.didUserLike(reply: reply) {
                self.post.didLike = true
            } else {
                self.post.didLike = false
            }
        }
    }
    
    func checkIfUserSavedPost() async throws {
        switch model.postType {
        case .post(let post):
            if try await model.didUserSave(post: post) {
                self.post.didSave = true
            } else {
                self.post.didSave = false
            }
        case .reply(let reply):
            if try await model.didUserSave(reply: reply) {
                self.post.didSave = true
            } else {
                self.post.didSave = false
            }
        }
    }
    
    func checkForUserActivity() async {
        do {
            try await checkIfUserLikedPost()
            try await checkIfUserSavedPost()
        } catch {
            print("DEBUG: Failed to check for user post activity.")
        }
    }
}

#Preview {
    PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(Preview.post)), onReplyTapped: {_ in })
}
