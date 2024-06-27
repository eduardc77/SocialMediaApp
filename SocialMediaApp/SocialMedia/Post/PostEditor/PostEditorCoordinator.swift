//
//  PostEditorCoordinator.swift
//  SocialMedia
//

import SwiftUI

struct PostEditorCoordinator: View {
    @EnvironmentObject private var tabRouter: AppScreenRouter
    @Environment(ModalScreenRouter.self) private var modalRouter
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation

    var body: some View {
        if prefersTabNavigation {
            Color.clear
                .onChange(of: tabRouter.selection) { oldValue, _ in
                    if tabRouter.selection == .newPost {
                        modalRouter.presentSheet(destination: PostSheetDestination.newPost)
                        self.tabRouter.selection = oldValue
                    }
                }
        } else {
            PostEditorView()
        }
    }
}
