//
//  AppTabView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct AppTabView: View {
    @EnvironmentObject private var settings: AppSettings
    @StateObject private var tabRouter = AppTabRouter()
    @StateObject private var modalRouter = ModalScreenRouter()
    
    var body: some View {
        TabView(selection: $tabRouter.selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem {
                        Image(systemName: screen.icon)
                            .environment(\.symbolVariants, tabRouter.selection == screen ? .fill : .none)
                    }
            }
        }
        .tint(settings.theme.color)
        .sheet(item: $modalRouter.presentedSheet, content: sheetContent)
        .alert($modalRouter.alert)
        .onOpenURL { url in
        }
        .environmentObject(tabRouter)
        .environmentObject(modalRouter)
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private func sheetContent(_ content: AnyIdentifiable) -> some View {
        if let destination = content.destination as? PostSheetDestination {
            switch destination {
            case .newPost:
                PostEditorView()
            case .reply(let post):
                PostReplyView(post: post)
            }
        } else if let destination = content.destination as? ProfileSheetDestination {
            switch destination {
            case .editProfile(let model, let imageData):
                EditProfileView(model: model, imageData: imageData)
            case .userRelations(let user):
                UserRelationsView(user: user)
            }
        }
    }
}

enum PostSheetDestination: Identifiable {
    case newPost
    case reply(post: Post)
    
    var id: String { UUID().uuidString }
}

enum ProfileSheetDestination: Identifiable {
    case editProfile(model: CurrentUserProfileViewModel, imageData: ImageData)
    case userRelations(user: User)
    
    var id: String { UUID().uuidString }
}

#Preview {
    AppTabView()
}
