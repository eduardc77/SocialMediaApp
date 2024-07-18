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
    var router: Router
    let postGridType: PostGridType
    @Binding var loading: Bool
    var loadingIndicatorHidden: Bool = false
    var endReached: Bool
    var itemsPerPage: Int = 20
    var contentUnavailableText: String = ""
    var loadNewPage: (() async throws -> Void)? = nil
    
    @Environment(ModalScreenRouter.self) private var modalRouter
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
                    postGridStack(posts)
                }
                
            case .replies(let replies):
                if replies.isEmpty, !loading {
                    ContentUnavailableView(
                        "No Content",
                        systemImage: "doc.richtext",
                        description: Text(contentUnavailableText)
                    )
                } else {
                    replyGridStack(replies)
                }
            }
        }
        .padding(10)
        .overlay(alignment: .bottom) {
            if loading { ProgressView() }
        }
    }
}

private extension PostGrid {
    func postGridStack(_ posts: [Post]) -> some View {
        LazyVGrid(columns: gridItems) {
            ForEach(posts, id: \.self) { post in
                ZStack {
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
    
    func replyGridStack(_ replies: [Reply]) -> some View {
        LazyVGrid(columns: gridItems) {
            ForEach(replies, id: \.self) { reply in
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

#Preview {
    @State var loading: Bool = false
    
    return ScrollView {
        PostGrid(router: ViewRouter(), postGridType: .posts([Preview.post, Preview.post2]), loading: $loading, endReached: false, itemsPerPage: 10)
            .environment(ViewRouter())
            .environment(ModalScreenRouter())
    }
}
