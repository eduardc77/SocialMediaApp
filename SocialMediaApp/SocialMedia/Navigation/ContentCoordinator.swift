//
//  ContentCoordinator.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaUI
import SocialMediaNetwork


struct ContentCoordinator: View {
    @State private var appRouter = AppScreenRouter()
    @State private var modalRouter = ModalScreenRouter()
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ContentView()
            .sheet(item: $modalRouter.presentedSheet, content: sheetContent)
            .alert($modalRouter.alert)
            .onReceive(appRouter.$urlString) { newValue in
                guard let urlString = newValue, let url = URL(string: urlString) else { return }
                openURL(url)
            }
            .environmentObject(appRouter)
            .environment(modalRouter)
    }
    
    @MainActor
    @ViewBuilder
    private func sheetContent(_ content: AnyIdentifiable) -> some View {
        if let destination = content.destination as? PostSheetDestination {
            switch destination {
            case .newPost:
                PostEditorView()
            case .reply(let postType):
                ReplyView(postType: postType)
            }
        } else if let destination = content.destination as? ProfileSheetDestination {
            switch destination {
            case .editProfile(let model):
                EditProfileView(model: model)
            case .userRelations(let user):
                UserRelationsCoordinator(user: user)
            }
        }
    }
}

enum PostSheetDestination: Identifiable {
    case newPost
    case reply(postType: PostType)
    
    var id: String { UUID().uuidString }
}

enum ProfileSheetDestination: Identifiable {
    case editProfile(model: CurrentUserProfileHeaderModel)
    case userRelations(user: User)
    
    var id: String { UUID().uuidString }
}

#Preview {
    ContentCoordinator()
        .environmentObject(AppSettings())
}
