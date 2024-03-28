//
//  PostGrid.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

enum PostGridType {
    case posts([Post])
    case replies([PostReply])
}

struct PostGrid: View {
    let postGridType: PostGridType
    @Binding var isLoading: Bool
    var itemsPerPage: Int = 20
    var noContentText: String = "No Content"
    
    var fetchNewPage: (() async throws -> Void)? = nil
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var isCompact: Bool {
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    private var profileImageSize: ImageSize {
#if os(iOS)
        return isCompact ? .small : .medium
#else
        return isCompact ? .xxSmall : .medium
#endif
    }
    
    private var itemSize: Double {
#if os(iOS)
        isCompact ? 400 : 300
#elseif os(macOS)
        600
#endif
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize), spacing: 20, alignment: .top)]
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            
            switch postGridType {
            case .posts(let posts):
                Group {
                    if posts.isEmpty, !isLoading {
                        VStack {
                            ContentUnavailableView(
                                noContentText,
                                systemImage: "doc.richtext",
                                description: Text("")
                            )
                        }
                    } else {
                        ForEach(Array(posts.enumerated()), id: \.element) { index, post in
                            ZStack(alignment: .top) {
                                NavigationLink(value: post) {
                                    Color.secondaryGroupedBackground.clipShape(.containerRelative)
                                }
                                .buttonStyle(.plain)
                                
                                PostGridItem(postType: .post(post), profileImageSize: profileImageSize)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .contentShape(.containerRelative)
                            .containerShape(.rect(cornerRadius: 8))
                            .onAppear {
                                if let fetchNewPage = fetchNewPage, !isLoading, !posts.isEmpty, index == posts.count - 1 {
                                    isLoading = true
                                    
                                    Task {
                                        try await fetchNewPage()
                                        isLoading = false
                                    }
                                }
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
                        
                        PostGridItem(postType: .reply(reply), profileImageSize: profileImageSize)
                    }
                    .contentShape(.containerRelative)
                    .containerShape(.rect(cornerRadius: 8))
                    .onAppear {
                        if let fetchNewPage = fetchNewPage, !isLoading, !replies.isEmpty, index == replies.count - 1 {
                            isLoading = true
                            
                            Task {
                                try await fetchNewPage()
                                isLoading = false
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
//    PostGrid(postGridType: .posts([Post(id: "", ownerUid: "", caption: "", timestamp: <#T##Timestamp#>, likes: <#T##Int#>, replyCount: <#T##Int#>, imageUrl: <#T##String?#>, user: <#T##User?#>, didLike: <#T##Bool?#>, didSave: <#T##Bool?#>)]), fetchNewPage: <#T##() async throws -> Void#>: [], fetchNewPage: {})
//}
