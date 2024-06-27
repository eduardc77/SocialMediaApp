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
    @Binding var loading: Bool
    var endReached: Bool
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
#else
        600
#endif
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize), spacing: 20, alignment: .top)]
    }
    
    var body: some View {
        Group {
            switch postGridType {
            case .posts(let posts):
                if posts.isEmpty, !loading {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.richtext",
                        description: Text(contentUnavailableText)
                    )
                } else {
                    LazyVGrid(columns: gridItems) {
                        ForEach(posts) { post in
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
                        }
                        if let loadNewPage = loadNewPage, !loading {
                            FooterLoadingView(hidden: !posts.isEmpty && endReached, loading: loading) {
                                loading = true
                                Task {
                                    try await loadNewPage()
                                    loading = false
                                }
                            }
                        }
                    }
                }
                
            case .replies(let replies):
                if replies.isEmpty, !loading {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.richtext",
                        description: Text(contentUnavailableText)
                    )
                } else {
                    LazyVGrid(columns: gridItems) {
                        ForEach(replies) { reply in
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
                        }
                        if let loadNewPage = loadNewPage, !loading {
                            FooterLoadingView(hidden: !replies.isEmpty && endReached, loading: loading) {
                                loading = true
                                Task {
                                    try await loadNewPage()
                                    loading = false
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .overlay(alignment: .bottom) {
            if loading { ProgressView() }
        }
    }
}

#Preview {
    @State var loading: Bool = false
    
    return ScrollView {
        PostGrid(router: FeedViewRouter(), postGridType: .posts([Preview.post, Preview.post2]), loading: $loading, endReached: false, itemsPerPage: 10)
            .environmentObject(FeedViewRouter())
            .environmentObject(ModalScreenRouter())
    }
}
