////
////  PostGridViewModel.swift
////  SocialMedia
////
////  Created by iMac on 25.03.2024.
////
//
//import SwiftUI
//import Combine
//import SocialMediaNetwork
//import Firebase
//
//enum PostGridType {
//    case forYouPosts
//    case followingPosts
//    case postReplies(post: Post)
//    case userReplies(user: SocialMediaNetwork.User)
//    case userPosts(userID: String)
//    case userLikes(userID: String)
//    case userSaves(userID: String)
//}
//
//@MainActor
//final class PostGridViewModel: ObservableObject {
//    var postGridType: PostGridType
//    @Published var posts = [Post]()
//    
//    @Published var isLoading = false
//    
//    var itemsPerPage: Int = 10
//    
//    private var noMoreItemsToFetch: Bool = false
//    var lastPostDocument: DocumentSnapshot?
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    @Published var pageCount: Int = 0
//    
//    init(postGridType: PostGridType) {
//        self.postGridType = postGridType
//    }
//    
//    @MainActor
//    func addListenersForFeed() {
//        PostService.removeCurrentListener()
//        
//        PostService.addListenerForFeed()
//            .sink { completion in
//                
//            } receiveValue: { [weak self] documentChangeType, lastDocument in
//                guard let self = self else { return }
//                
//                Task {
//                    switch documentChangeType {
//                    case .added(let post):
//                        try await self.add(post)
//                        
//                    case .modified(let post):
//                        try await self.modify(post)
//                        
//                    case .removed(let post):
//                        self.remove(post)
//                        
//                    case .none: break
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    
//    func refreshFeed() async throws {
//        posts.removeAll()
//        noMoreItemsToFetch = false
//        lastPostDocument = nil
//        pageCount = 0
//        cancellables.forEach { $0.cancel() }
//        cancellables.removeAll()
//        try await loadMorePosts()
//    }
////
////    func fetchFeedForCurrentFilter() async throws {
////        switch currentFilter {
////        case .forYou:
////            try await fetchForYouPosts()
////        case .following:
////            try await fetchFollowingPosts()
////        }
////    }
////    
//    func refreshFeedForCurrentFilter() async throws {
////        switch currentFilter {
////        case .forYou:
////            try await refreshForYouFeed()
////        case .following:
////            try await refreshFollowingFeed()
////        }
//    }
//    
//    func addListenerIfRemoved() {
//        if PostService.currentListenerRemoved {
//            addListenersForFeed()
//        }
//    }
//    
//    func loadMorePosts() async throws {
//        guard !noMoreItemsToFetch else {
//            addListenerIfRemoved()
//            return
//        }
//        isLoading = true
//        PostService.removeCurrentListener()
//        
//        var (newPosts, lastPostDocument): ([Post]?, DocumentSnapshot?)
//        var (newReplies, lastReplyDocument): ([PostReply]?, DocumentSnapshot?)
//        
//        switch postGridType {
//        case .forYouPosts:
//            (newPosts, lastPostDocument) = try await PostService.fetchForYouPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
//        case .followingPosts:
//            break
////            (newPosts, lastPostDocument) = try await PostService.fetchUserFollowingPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
//        case .postReplies(let post):
//            (newReplies, lastPostDocument) = try await PostService.fetchPostReplies(forPost: post, countLimit: itemsPerPage, descending: true, lastDocument: lastReplyDocument)
//        case .userReplies(let user):
//            (newReplies, lastPostDocument) = try await PostService.fetchPostReplies(forUser: user, countLimit: itemsPerPage, descending: true, lastDocument: lastReplyDocument)
//        case .userPosts(let userID):
//            (newPosts, lastPostDocument) = try await PostService.fetchUserPosts(userID: userID, countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
//        case .userLikes(let userID):
//            (newPosts, lastPostDocument) = try await PostService.fetchUserLikedPosts(userID: userID, countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
//        case .userSaves(let userID):
//            (newPosts, lastPostDocument) = try await PostService.fetchUserSavedPosts(userID: userID, countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
//        }
// 
//        guard let newPosts = newPosts, !newPosts.isEmpty else {
//            self.noMoreItemsToFetch = true
//            self.isLoading = false
//            self.lastPostDocument = nil
//            self.addListenerIfRemoved()
//            return
//        }
//        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
//            guard let self = self else {
//                self?.isLoading = false
//                print("FeedViewModel object not found.")
//                self?.addListenerIfRemoved()
//                return
//            }
//            var userDataPosts = [Post]()
//            
//            for post in newPosts {
//                group.addTask { return try await self.fetchPostUserData(post: post) }
//            }
//            for try await post in group {
//                userDataPosts.append(post)
//            }
//            
//            if let lastPostDocument {
//                self.lastPostDocument = lastPostDocument
//                self.noMoreItemsToFetch = false
//            } else {
//                self.noMoreItemsToFetch = true
//                self.lastPostDocument = nil
//            }
//            self.posts.append(contentsOf: userDataPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
//            
//            self.isLoading = false
//            self.addListenerIfRemoved()
//        }
//    }
//    
//    
//}
//
//
////
////private func fetchSavedPostsMetadata() async throws {
////    await withThrowingTaskGroup(of: Void.self, body: { group in
////        for savedPost in self.saved {
////            group.addTask { try await self.fetchSavedPostData(for: savedPost) }
////        }
////    })
////}
////
////private func fetchSavedPostData(for savedPost: Post) async throws {
////    guard let savedPostIndex = saved.firstIndex(where: { $0.id == savedPost.id }) else { return }
////    saved[savedPostIndex].user = try await UserService.fetchUser(withUID: savedPost.ownerUID)
////}
////guard let likedPostIndex = liked.firstIndex(where: { $0.id == likedPost.id }) else { return }
////liked[likedPostIndex].user = try await UserService.fetchUser(withUID: likedPost.ownerUID)
////self.replies = try await PostService.fetchPostReplies(forUser: user)
////var userPosts = try await PostService.fetchUserPosts(uid: userID)
////self.replies = try await PostService.fetchPostReplies(forPost: post)
////try await PostService.fetchPosts(by: category)
////
////
////
//
//private extension PostGridViewModel {
//    func add(_ post: Post) async throws {
//        guard !self.posts.contains(where: { $0.id == post.id }),
//              let index = self.posts.firstIndex(where: { $0.id != post.id }) else { return }
//        
//        let userDataPost = try await self.fetchPostUserData(post: post)
//        withAnimation {
//            self.posts.insert(userDataPost, at: index)
//        }
//    }
//    
//    func modify(_ post: Post) async throws {
//        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
//
//        guard posts[index].id == post.id, posts[index] != post else { return }
//       
//        if posts[index].likes != post.likes {
//            posts[index].likes = post.likes
//        }
//        if posts[index].replies != post.replies {
//            posts[index].replies = post.replies
//        }
//        if posts[index].reposts != post.reposts {
//            posts[index].reposts = post.reposts
//        }
//    }
//    
//    func remove(_ post: Post) {
//        withAnimation {
//            posts.removeAll(where: { $0.id == post.id })
//        }
//    }
//   
//    
//    
////    func refreshFollowingFeed() async throws {
////        posts.removeAll()
////        noMoreItemsToFetch = false
////        lastPostDocument = nil
////        try await fetchFollowingPosts()
////    }
//    
//   
//    
////    func fetchFollowingPosts() async throws {
////        guard !noMoreItemsToFetch else { return }
////        isLoading = true
////        
////        let (newPostIDs, lastDocument) = try await PostService.fetchPostIDs(countLimit: itemsPerPage, lastDocument: lastFollowingPostDocument)
////        
////        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
////            guard let self = self else { return }
////            var followingPosts = [Post]()
////            
////            guard !newPostIDs.isEmpty else {
////                self.noMoreItemsToFetch = true
////                self.isLoading = false
////                return
////            }
////            for postID in newPostIDs {
////                group.addTask { return try await PostService.fetchPost(postID: postID) }
////            }
////            for try await post in group {
////                followingPosts.append(try await fetchPostUserData(post: post))
////            }
////            if let lastDocument {
////                self.lastFollowingPostDocument = lastDocument
////                self.noMoreItemsToFetch = false
////            } else {
////                self.noMoreItemsToFetch = true
////            }
////            
////            self.followingPosts.append(contentsOf: followingPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
////            self.isLoading = false
////        }
////    }
//    
//    func fetchPostUserData(post: Post) async throws -> Post {
//        var result = post
//        
//        async let user = try await UserService.fetchUser(userID: post.ownerUID)
//        result.user = try await user
//        
//        return result
//    }
//}
