//
//  ContentButtonsView.swift
//  SocialMedia
//

import SwiftUI

struct ContentButtonsView: View {
    @ObservedObject var model: ContentButtonsViewModel
    
    @EnvironmentObject var modalRouter: ModalScreenRouter
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PostButtonType.allCases, id: \.self) { buttonType in
                switch buttonType {
                case .like:
                    ContentButton(count: model.post?.likes ?? 0,
                                  buttonType: buttonType,
                                  isActive: model.didLike) {
                        likeButtonTapped()
                    }
                    Divider().padding(.vertical, 5)
                case .reply:
                    ContentButton(count: model.post?.replies ?? 0,
                                  buttonType: buttonType) {
                        if let post = model.post {
                            modalRouter.presentSheet(destination: PostSheetDestination.reply(post: post))
                        }
                    }
                    Divider().padding(.vertical, 5)
                case .repost:
                    ContentButton(count: model.temporaryRepostCount,
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
                    ContentButton(count: model.didSave ? 1 : 0,
                                  buttonType: buttonType,
                                  isActive: model.didSave) {
                        saveButtonTapped()
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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

struct PostButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentButtonsView(model: ContentButtonsViewModel(contentType: .post(preview.post)))
    }
}
