//
//  UserRepliesView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserRepliesView: View {
    @StateObject var model: UserRepliesViewModel
    var router: any Router
    let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(router: any Router, user: User, contentUnavailableText: String) {
        self.router = router
        self._model = StateObject(wrappedValue: UserRepliesViewModel(user: user))
        self.contentUnavailableText = contentUnavailableText
    }
    
    var body: some View {
        RepliesGrid(router: router,
                    replies: model.replies,
                    loading: $model.loading,
                    endReached: model.noMoreItemsToFetch,
                    itemsPerPage: model.itemsPerPage,
                    contentUnavailableText: contentUnavailableText,
                    loadNewPage: model.loadMoreReplies)
        .onAppear {
            Task {
                if model.replies.isEmpty {
                    try await model.loadMoreReplies()
                }
//                model.addListenerForPostUpdates()
            }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .replies, !model.replies.isEmpty {
                Task { try await model.refresh() }
            }
        }
    }
}


import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct RepliesGrid: View {
    var router: any Router
    let replies: [Reply]
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
#elseif os(macOS)
        600
#endif
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize), spacing: 20, alignment: .top)]
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            if replies.isEmpty, !loading {
                ContentUnavailableView(
                    "No Content",
                    systemImage: "doc.richtext",
                    description: Text(contentUnavailableText)
                )
            } else {
                ForEach(replies) { reply in
                    ZStack(alignment: .top) {
                        NavigationButton {
                            if let post = reply.post {
                                router.push(PostType.post(post))
                            } else {
                                router.push(PostType.reply(reply))
                            }
                        } label: {
                            Color.secondaryGroupedBackground.clipShape(.containerRelative)
                        }
                        
                        ReplyGridItem(router: router, reply: reply, onReplyTapped: { postType in
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
        .padding(10)
        .overlay(alignment: .bottom) {
            if loading { ProgressView() }
        }
    }
}

#Preview {
    @State var loading: Bool = false
    
    return ScrollView {
        RepliesGrid(router: FeedViewRouter(), replies: [Preview.reply, Preview.reply], loading: $loading, endReached: false, itemsPerPage: 10)
            .environmentObject(FeedViewRouter())
            .environmentObject(ModalScreenRouter())
    }
}
