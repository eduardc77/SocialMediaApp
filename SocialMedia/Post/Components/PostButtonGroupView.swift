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
    
    @State private var loading: Bool = false
    
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
            guard !loading else { return }
            Task {
                await checkForUserActivity()
            }
        })
        .task {
            guard !loading else { return }
            await checkForUserActivity()
        }
    }
    
    func likeButtonTapped() async throws {
        guard !loading else { return }
        loading = true
        
        if post.didLike {
            try await model.unlikePost()
            loading = false
            post.didLike = false
        } else {
            post.didLike = true
            try await model.likePost()
            loading = false
        }
    }
    
    func saveButtonTapped() async throws {
        guard !loading else { return }
        loading = true
        
        if post.didSave {
            try await model.unsavePost()
            post.didSave = false
            loading = false
        } else {
            try await model.savePost()
            post.didSave = true
            loading = false
        }
    }
    
    func checkIfUserLikedPost() async throws {
        switch model.postType {
        case .post(let post):
            if try await PostService.checkIfUserLikedPost(post) {
                self.post.didLike = true
            } else {
                self.post.didLike = false
            }
        case .reply(let reply):
            if try await ReplyService.checkIfUserLikedReply(reply) {
                self.post.didLike = true
            } else {
                self.post.didLike = false
            }
        }
    }
    
    func checkIfUserSavedPost() async throws {
        switch model.postType {
        case .post(let post):
            if try await PostService.checkIfUserSavedPost(post) {
                self.post.didSave = true
            } else {
                self.post.didSave = false
            }
        case .reply(let reply):
            if try await ReplyService.checkIfUserSavedReply(reply) {
                self.post.didSave = true
            } else {
                self.post.didSave = false
            }
        }
    }
    
    func checkForUserActivity() async {
        do {
            loading = true
            try await checkIfUserLikedPost()
            try await checkIfUserSavedPost()
            loading = false
        } catch {
            print("DEBUG: Failed to check for user post activity.")
            loading = false
        }
    }
}

#Preview {
    PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(Preview.post)), onReplyTapped: {_ in })
}
