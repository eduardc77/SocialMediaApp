//
//  ContentView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ContentView: View {
    @StateObject private var model = ContentViewModel()
    @StateObject private var tabRouter = AppTabRouter()
    @StateObject private var modalRouter = ModalScreenRouter()
    
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.openURL) private var openURL
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if model.userSession == nil || model.userSession?.uid == nil {
                LoginView()
            } else {
                Group {
                    if prefersTabNavigation {
                        AppTabView(appRouter: tabRouter)
                    } else {
                        NavigationSplitView {
                            AppSidebarList(selection: $tabRouter.selection)
                        } detail: {
                            AppDetailColumn(screen: tabRouter.selection)
                        }
                    }
                }
                .tint(settings.theme.color)
                .sheet(item: $modalRouter.presentedSheet, content: sheetContent)
                .alert($modalRouter.alert)
                .onReceive(tabRouter.$urlString) { newValue in
                    guard let urlString = newValue, let url = URL(string: urlString) else { return }
                    openURL(url)
                }
                .environmentObject(tabRouter)
                .environmentObject(modalRouter)
                .ignoresSafeArea(.keyboard)
            }
    }
    
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
    case reply(postType: PostType)
    
    var id: String { UUID().uuidString }
}

enum ProfileSheetDestination: Identifiable {
    case editProfile(model: CurrentUserProfileViewModel, imageData: ImageData)
    case userRelations(user: User)
    
    var id: String { UUID().uuidString }
}

#Preview {
    ContentView()
}
