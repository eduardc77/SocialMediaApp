//
//  PostGrid.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

enum PostGridType {
    case posts([Post])
    case replies([Reply])
}

struct PostGrid: View {
    var router: any Router
    let postGridType: PostGridType
    @Binding var isLoading: Bool
    var itemsPerPage: Int = 20
    var contentUnavailableText: String = ""
    
    var loadNewPage: (() async throws -> Void)? = nil
    
    @EnvironmentObject private var modalRouter: ModalScreenRouter
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
                if posts.isEmpty, !isLoading {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.richtext",
                        description: Text(contentUnavailableText)
                    )
                } else {
                    ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                        ZStack(alignment: .top) {
                            NavigationButton {
                                router.push(PostType.post(post))
                            } label: {
                                Color.secondaryGroupedBackground.clipShape(.containerRelative)
                            }
                            
                            PostGridItem(router: router, postType: .post(post), profileImageSize: profileImageSize, onReplyTapped: { postType in
                                modalRouter.presentSheet(destination: PostSheetDestination.reply(postType: postType))
                            })
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .contentShape(.containerRelative)
                        .containerShape(.rect(cornerRadius: 8))
                        .onAppear {
                            if let loadNewPage = loadNewPage, !isLoading, !posts.isEmpty, index == posts.count - 1 {
                                isLoading = true
                                
                                Task {
                                    try await loadNewPage()
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
                
            case .replies(let replies):
                if replies.isEmpty, !isLoading {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.richtext",
                        description: Text(contentUnavailableText)
                    )
                } else {
                    ForEach(Array(replies.enumerated()), id: \.offset) { index, reply in
                        ZStack(alignment: .top) {
                            NavigationButton {
                                router.push(PostType.reply(reply))
                            } label: {
                                Color.secondaryGroupedBackground.clipShape(.containerRelative)
                            }
                            
                            PostGridItem(router: router, postType: .reply(reply), profileImageSize: profileImageSize, onReplyTapped: { postType in
                                modalRouter.presentSheet(destination: PostSheetDestination.reply(postType: postType))
                            })
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .contentShape(.containerRelative)
                        .containerShape(.rect(cornerRadius: 8))
                        .onAppear {
                            if let loadNewPage = loadNewPage, !isLoading, !replies.isEmpty, index == replies.count - 1 {
                                isLoading = true
                                
                                Task {
                                    try await loadNewPage()
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .overlay(alignment: .bottom) {
            if isLoading { ProgressView() }
        }
    }
}

#Preview {
    @State var isLoading: Bool = false
    
    return ScrollView {
        PostGrid(router: FeedViewRouter(), postGridType: .posts([Preview.post, Preview.post2]), isLoading: $isLoading, itemsPerPage: 10)
            .environmentObject(FeedViewRouter())
            .environmentObject(ModalScreenRouter())
    }
}
