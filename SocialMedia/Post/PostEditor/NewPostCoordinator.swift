//
//  NewPostCoordinator.swift
//  SocialMedia
//

import SwiftUI

struct NewPostCoordinator: View {
    @EnvironmentObject private var tabRouter: AppTabRouter
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    
    var body: some View {
        Color.clear
            .onChange(of: tabRouter.selection) { oldValue, newValue in
                if tabRouter.selection == .newPost {
                    modalRouter.presentSheet(destination: PostSheetDestination.newPost)
                    self.tabRouter.selection = oldValue
                }
            }
    }
}
