//
//  NewPostCoordinator.swift
//  SocialMedia
//

import SwiftUI

struct NewPostCoordinator: View {
    @EnvironmentObject private var tabRouter: AppTabRouter
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if prefersTabNavigation {
            Color.clear
                .onChange(of: tabRouter.selection) { oldValue, newValue in
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
