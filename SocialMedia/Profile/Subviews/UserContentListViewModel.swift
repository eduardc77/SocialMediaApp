//
//  UserContentListViewModel.swift
//  SocialMedia
//

import Combine
import SocialMediaNetwork
import Firebase

@MainActor
final class UserContentListViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var replies = [PostReply]()
    @Published var liked = [Post]()
    @Published var saved = [Post]()
    @Published var itemsPerPage: Int = 10
    
    var likedPostsListener: ListenerRegistration?
    var savedPostsListener: ListenerRegistration?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let user: SocialMediaNetwork.User
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
    }
    
    // MARK: - User Posts
    
    func fetchUserPosts() async throws {
        guard let userID = user.id else { return }
        var userPosts = try await PostService.fetchUserPosts(uid: userID)
        
        for i in 0 ..< userPosts.count {
            userPosts[i].user = self.user
        }
        self.posts = userPosts
    }
    
    
    
    // MARK: - User Replies
    
    func fetchUserReplies() async throws {
        self.replies = try await PostService.fetchPostReplies(forUser: user)
        try await fetchReplyMetadata()
    }
    
    private func fetchReplyMetadata() async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for reply in self.replies {
                group.addTask { try await self.fetchPostReplyData(for: reply) }
            }
        })
    }
    
    private func fetchPostReplyData(for reply: PostReply) async throws {
        guard let replyIndex = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        async let post = try await PostService.fetchPost(postID: reply.postID)
        
        let postOwnerUID = try await post.ownerUID
        async let user = try await UserService.fetchUser(withUID: postOwnerUID)
        
        var postCopy = try await post
        postCopy.user = try await user
        replies[replyIndex].post = postCopy
    }
    
    // MARK: - User Liked Posts
//    
//    func fetchUserLikedPosts() async throws {
//        guard let userID = user.id else { return }
//        
//        self.liked = try await PostService.fetchLikedPosts(forUserID: userID)
//        try await fetchLikedPostsMetadata()
//    }
    
    private func fetchLikedPostsMetadata() async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for likedPost in self.liked {
                group.addTask { try await self.fetchLikedPostData(for: likedPost) }
            }
        })
    }
    
    private func fetchLikedPostData(for likedPost: Post) async throws {
        guard let likedPostIndex = liked.firstIndex(where: { $0.id == likedPost.id }) else { return }
        liked[likedPostIndex].user = try await UserService.fetchUser(withUID: likedPost.ownerUID)
    }

    func addListenerForLikedPosts() {
        guard let userID = user.id else { return }
        let addListener = PostService.addListenerForLikedPosts(forUserID: userID)
        likedPostsListener = addListener.listener
        addListener.publisher
            .sink { completion in
                
            } receiveValue: { [weak self] _, lastDocument in
                guard let self = self else { return }

                Task(priority: .background) { @MainActor in
                    self.liked = try await PostService.fetchLikedPosts(forUserID: userID)
                    try await self.fetchLikedPostsMetadata()
                }
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Saved Posts
    
    func fetchUserSavedPosts() async throws {
        guard let userID = user.id else { return }
        
        self.saved = try await PostService.fetchSavedPosts(forUserID: userID)
        try await fetchSavedPostsMetadata()
    }
    
    private func fetchSavedPostsMetadata() async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for savedPost in self.saved {
                group.addTask { try await self.fetchSavedPostData(for: savedPost) }
            }
        })
    }
    
    private func fetchSavedPostData(for savedPost: Post) async throws {
        guard let savedPostIndex = saved.firstIndex(where: { $0.id == savedPost.id }) else { return }
        saved[savedPostIndex].user = try await UserService.fetchUser(withUID: savedPost.ownerUID)
    }
    
    func addListenerForSavedPosts() {
        guard let userID = user.id else { return }
        let addListener = PostService.addListenerForSavedPosts(forUserID: userID)
        savedPostsListener = addListener.listener
        addListener.publisher
            .sink { completion in
                
            } receiveValue: { [weak self] _, lastDocument in
                guard let self = self else { return }
 
                Task(priority: .background) { @MainActor in
                    try await self.fetchUserSavedPosts()
                }
            }
            .store(in: &cancellables)
    }
    
    func noContentText(filter: ProfilePostFilter) -> String {
        let name = user.isCurrentUser ? "You" : user.username
        let nextWord = user.isCurrentUser ? "haven't" : "hasn't"
        let contentType = filter == .replies ? "replies" : "posts"
      
        return "\(name) \(nextWord) \(filter.noContentFilterVerb) any \(contentType) yet."
    }
}
