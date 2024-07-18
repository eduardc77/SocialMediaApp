//
//  PostButtonGroupView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct PostButtonGroupView: View {
    @State private var model: PostButtonGroupViewModel
    private let onReplyTapped: ((PostType) -> ())?
    
    init(postType: PostType, onReplyTapped: ((PostType) -> ())?) {
        model = PostButtonGroupViewModel(postType: postType)
        self.onReplyTapped = onReplyTapped
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PostButtonType.allCases) { buttonType in
                switch buttonType {
                case .like:
                    PostButton(count: model.tempPost.numberOfLikes,
                               active: model.tempPost.didLike,
                               buttonType: buttonType) {
                        Task {
                            try await model.likeButtonTapped()
                        }
                    }
                    Divider().padding(.vertical, 5)
                    
                case .reply:
                    PostButton(count: model.tempPost.numberOfReplies,
                               active: false,
                               buttonType: buttonType) {
                        onReplyTapped?(model.postType)
                    }
                    Divider().padding(.vertical, 5)
                    
                case .repost:
                    PostButton(count: model.tempPost.numberOfReposts,
                               active: false,
                               buttonType: buttonType) {
                        
                    }
                    Divider().padding(.vertical, 5)
                    
                case .save:
                    PostButton(count: model.tempPost.didSave ? 1 : 0,
                               active: model.tempPost.didSave,
                               buttonType: buttonType) {
                        Task {
                            try await model.saveButtonTapped()
                        }
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        
        .task {
            guard !model.loading else { return }
            await model.checkForUserActivity()
        }
    }
}

#Preview {
    PostButtonGroupView(postType: .post(Preview.post), onReplyTapped: {_ in })
}
