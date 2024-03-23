//
//  ContentGrid.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

enum ContentGridType {
    case posts([Post])
    case replies([PostReply])
}

struct ContentGrid: View {
    let contentGridType: ContentGridType
    @Binding var pageCount: Int
    @Binding var isLoading: Bool
    var itemsPerPage: Int = 10
 
    var fetchNewPage: (() async throws -> Void)? = nil

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var useProfileImageSize: Bool {
    #if os(iOS)
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    #endif
        //        if dynamicTypeSize >= .xxxLarge {
        //            return true
        //        }
        //        return false
    }
    
    private var profileImageSize: ImageSize {
    #if os(iOS)
        return useProfileImageSize ? .small : .large
    #else
        return useProfileImageSize ? .xSmall : .medium
    #endif
    }
    
    private var itemSize: Double {
        useProfileImageSize ? 300 : 400
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize), spacing: 20, alignment: .top)]
    }
    
    //    private var itemsPerPage: Int {
    //        #if os(iOS)
    //        if sizeClass == .compact {
    //            return pageItemLimit
    //        } else {
    //            return pageItemLimit * 2
    //        }
    //        #endif
    //    }
    
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            switch contentGridType {
                case .posts(let posts):
                    ForEach(Array(posts.enumerated()), id: \.element) { index, post in
                        ZStack {
                            NavigationLink(value: post) {
                                Color.secondaryGroupedBackground.clipShape(.containerRelative)
                            }
                            .buttonStyle(.plain)
                            
                            ContentGridItem(contentType: .post(post), profileImageSize: profileImageSize)
                        }
                        .contentShape(.containerRelative)
                        .containerShape(.rect(cornerRadius: 8))
                        .onAppear {
                            if let fetchNewPage = fetchNewPage, !isLoading, !posts.isEmpty, index == posts.count - 1 {
                                isLoading = true
                                
                                Task(priority: .background) { @MainActor in
                                    try await fetchNewPage()
                                    isLoading = false 
                                }
                            }
                        }
                    }
                
                case .replies(let replies):
                    ForEach(Array(replies.enumerated()), id: \.element) { index, reply in
                        ZStack {
                            NavigationLink(value: reply) {
                                Color.secondaryGroupedBackground.clipShape(.containerRelative)
                            }
                            .buttonStyle(.plain)
                            
                            ContentGridItem(contentType: .reply(reply), profileImageSize: profileImageSize)
                        }
                        .contentShape(.containerRelative)
                        .containerShape(.rect(cornerRadius: 8))
                        .onAppear {
                            if let fetchNewPage = fetchNewPage, !isLoading, replies.count >= itemsPerPage * pageCount, !replies.isEmpty, index == replies.count - 2 {
                                isLoading = true
                                
                                Task(priority: .background) { @MainActor in
                                    try await fetchNewPage()
                                    isLoading = false
                                    pageCount += 1
                                }
                            }
                        }
                    }
            }
        }
        .padding(10)
    }
}

//#Preview {
//    ContentGrid(contentGridType: .posts([Post(id: "", ownerUid: "", caption: "", timestamp: <#T##Timestamp#>, likes: <#T##Int#>, replyCount: <#T##Int#>, imageUrl: <#T##String?#>, user: <#T##User?#>, didLike: <#T##Bool?#>, didSave: <#T##Bool?#>)]), fetchNewPage: <#T##() async throws -> Void#>: [], fetchNewPage: {})
//}
