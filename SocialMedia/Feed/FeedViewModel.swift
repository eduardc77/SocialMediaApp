//
//  FeedViewModel.swift
//  SocialMedia
//

import Firebase
import Combine
import SocialMediaNetwork

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var forYouPosts = [Post]()
    @Published var followingPosts = [Post]()
    @Published var isLoading = false
    @Published var currentFilter: FeedFilter = .forYou
    
    var itemsPerPage: Int = 10
    
    private var noMoreItemsToFetch: Bool = false
    var lastForYouPostDocument: DocumentSnapshot?
    private var lastFollowingPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var pageCount: Int = 0
    
    var forYouFeedListeners = [ListenerRegistration?]()
    var reachEnd: Bool = false
    
    func addListenersForFeed() {
        guard !reachEnd else {
            return
        }
        isLoading = true
        
        let addListener = PostService.addListenerForFeed(countLimit: itemsPerPage, lastDocument: lastForYouPostDocument)
        addListener.publisher
            .sink { completion in
                
            } receiveValue: { [weak self] documentChangeType, lastDocument in
                guard let self = self else {
                    self?.isLoading = false
                    return
                }
                self.isLoading = true
                self.noMoreItemsToFetch = false
                self.lastForYouPostDocument = nil
                
                Task { @MainActor in
                    if let lastDocument {
                        self.lastForYouPostDocument = lastDocument
                        self.noMoreItemsToFetch = false
                    } else {
                        self.noMoreItemsToFetch = true
                        self.lastFollowingPostDocument = nil
                    }
                    
                    switch documentChangeType {
                        
                    case .added(let posts):
                        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                            guard let self = self else {
                                print("FeedViewModel object not found.")
                                return }
                            
                            guard !posts.isEmpty else {
                                //                        self.noMoreItemsToFetch = true
                                self.isLoading = false
                                self.lastFollowingPostDocument = nil
                                return
                            }
                            var userDataPosts = [Post]()
                            
                            for post in posts {
                                group.addTask { return try await self.fetchPostUserData(post: post) }
                            }
                            for try await post in group {
                                userDataPosts.append(post)
                            }
                            var sortedPosts = [Post]()
                            for post in userDataPosts {
                                if !self.forYouPosts.contains(where: { $0.id == post.id }) {
                                    sortedPosts.append(post)
                                } 
                            }
                            sortedPosts = sortedPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                            
                            if sortedPosts.count == 1, let newPost = sortedPosts.first {
                                self.forYouPosts.insert(newPost, at: 0)
                            } else {
                               
                                if !sortedPosts.isEmpty && sortedPosts.count == itemsPerPage, !reachEnd {
                                    self.forYouPosts.append(contentsOf: sortedPosts)
                                    forYouFeedListeners.append(addListener.listener)
                                   
                                } else {
                                    if !reachEnd {
                                        self.forYouPosts.append(contentsOf: sortedPosts)
                                        forYouFeedListeners.append(addListener.listener)
                                    }
                                    reachEnd = true
                                }
                                print(forYouFeedListeners.count)
                            }
                            
                        }
                    case .modified(let post):
                        for index in self.forYouPosts.indices {
                            try await self.modify(post, at: index)
                        }
                    case .removed(let post):
                        self.delete(post)
                    case .none:
                        print("NONE")
                    }
                    
                    
                    self.isLoading = false
                    
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchFeedForCurrentFilter() async throws {
        switch currentFilter {
        case .forYou:
            break
            //            try await fetchForYouPosts()
        case .following:
            break
            //            try await fetchFollowingPosts()
        }
    }
    
    
    func refreshFeedForCurrentFilter() async throws {
        switch currentFilter {
        case .forYou:
            try await refreshForYouFeed()
        case .following:
            try await refreshFollowingFeed()
        }
    }
    
    func removeListeners() {
        forYouFeedListeners.removeAll()
    }
}

private extension FeedViewModel {
    func add(_ post: Post) {
        
    }
    
    func modify(_ post: Post, at index: Int) async throws {
        if self.forYouPosts[index].id == post.id, self.forYouPosts[index] != post {
            self.forYouPosts[index] = try await self.fetchPostUserData(post: post)
        }
    }
    
    func delete(_ post: Post) {
        forYouPosts.removeAll(where: { $0.id == post.id })
    }
    
    func refreshForYouFeed() async throws {
        forYouPosts.removeAll()
        noMoreItemsToFetch = false
        lastForYouPostDocument = nil
        removeListeners()
        addListenersForFeed()
        pageCount = 0
        reachEnd = false
        //        try await fetchForYouPosts()
    }
    
    func refreshFollowingFeed() async throws {
        followingPosts.removeAll()
        noMoreItemsToFetch = false
        lastFollowingPostDocument = nil
        //        try await fetchFollowingPosts()
    }
    
    //    func fetchForYouPosts() async throws {
    //        guard !noMoreItemsToFetch else { return }
    //        isLoading = true
    //
    //        let (newPosts, lastDocument) = try await PostService.fetchPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastForYouPostDocument)
    //
    //        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
    //            guard let self = self else {
    //                print("FeedViewModel object not found.")
    //                return }
    //
    //            guard !newPosts.isEmpty else {
    //                self.noMoreItemsToFetch = true
    //                self.isLoading = false
    //                self.lastFollowingPostDocument = nil
    //                return
    //            }
    //            var forYouPosts = [Post]()
    //
    //            for post in newPosts {
    //                group.addTask { return try await self.fetchPostUserData(post: post) }
    //            }
    //            for try await post in group {
    //                forYouPosts.append(post)
    //            }
    //
    //            if let lastDocument {
    //                self.lastForYouPostDocument = lastDocument
    //                self.noMoreItemsToFetch = false
    //            } else {
    //                self.noMoreItemsToFetch = true
    //                self.lastFollowingPostDocument = nil
    //            }
    //            self.forYouPosts.append(contentsOf: forYouPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
    //            print("More: \(self.forYouPosts.count)")
    //            self.isLoading = false
    //        }
    //    }
    //
    //    func fetchFollowingPosts() async throws {
    //        guard !noMoreItemsToFetch else { return }
    //        isLoading = true
    //
    //        let (newPostIDs, lastDocument) = try await PostService.fetchPostIDs(countLimit: itemsPerPage, lastDocument: lastFollowingPostDocument)
    //
    //        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
    //            guard let self = self else { return }
    //            var followingPosts = [Post]()
    //
    //            guard !newPostIDs.isEmpty else {
    //                self.noMoreItemsToFetch = true
    //                self.isLoading = false
    //                return
    //            }
    //            for postID in newPostIDs {
    //                group.addTask { return try await PostService.fetchPost(postID: postID) }
    //            }
    //            for try await post in group {
    //                followingPosts.append(try await fetchPostUserData(post: post))
    //            }
    //            if let lastDocument {
    //                self.lastFollowingPostDocument = lastDocument
    //                self.noMoreItemsToFetch = false
    //            } else {
    //                self.noMoreItemsToFetch = true
    //            }
    //
    //            self.followingPosts.append(contentsOf: followingPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
    //            self.isLoading = false
    //        }
    //    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        
        async let user = try await UserService.fetchUser(withUID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}
