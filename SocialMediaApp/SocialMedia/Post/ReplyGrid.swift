//
//  ReplyGrid.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct RepliesGrid: View {
    var router: Router
    let replies: [Reply]
    @Binding var loading: Bool
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
                ForEach(replies, id: \.self) { reply in
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
    @Previewable @State var loading: Bool = false
    
    return ScrollView {
        RepliesGrid(router: ViewRouter(), replies: [Preview.reply, Preview.reply2], loading: $loading, endReached: false, itemsPerPage: 10)
            .environment(ViewRouter())
            .environment(ModalScreenRouter())
    }
}
