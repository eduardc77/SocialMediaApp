//
//  PostButtonGroupView.swift
//  SocialMedia
//

import SwiftUI

struct PostButtonGroupView: View {
    @ObservedObject var model: PostButtonGroupViewModel
    @EnvironmentObject var modalRouter: ModalScreenRouter
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PostButtonType.allCases, id: \.self) { buttonType in
                switch buttonType {
                case .like:
                    PostButton(count: model.numberOfLikes,
                                  buttonType: buttonType,
                                  isActive: model.didLike) {
                            likeButtonTapped()
                    }
                    Divider().padding(.vertical, 5)
                    
                case .reply:
                    PostButton(count: model.numberOfReplies,
                                  buttonType: buttonType) {
                            modalRouter.presentSheet(destination: PostSheetDestination.reply(postType: model.postType))
                    }
                    Divider().padding(.vertical, 5)
                    
                case .repost:
                    PostButton(count: model.temporaryRepostCount,
                                  buttonType: buttonType,
                                  isActive: model.temporaryRepostCount > 0) {
                        if model.temporaryRepostCount == 0 {
                            model.temporaryRepostCount += 1
                        } else {
                            model.temporaryRepostCount -= 1
                        }
                    }
                    Divider().padding(.vertical, 5)
                    
                case .save:
                    PostButton(count: model.didSave ? 1 : 0,
                                  buttonType: buttonType,
                                  isActive: model.didSave) {
                        saveButtonTapped()
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onFirstAppear {
            Task {
                try await model.checkIfUserLikedPost()
                try await model.checkIfUserSavedPost()

            }
        }
    }
    
    private func likeButtonTapped() {
        Task {
            if model.didLike {
                try await model.unlikePost()
            } else {
                try await model.likePost()
            }
        }
    }
    
    private func saveButtonTapped() {
        Task {
            if model.didSave {
                try await model.unsavePost()
            } else {
                try await model.savePost()
            }
        }
    }
}

struct PostButtonGroupView_Previews: PreviewProvider {
    static var previews: some View {
        PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(preview.post)))
    }
}
