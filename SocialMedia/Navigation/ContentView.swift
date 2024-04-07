//
//  ContentView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ContentView: View {
    @StateObject private var model = ContentViewModel()
    @EnvironmentObject private var appRouter: AppScreenRouter
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        Group {
            if model.userSession == nil || model.currentUser == nil {
                LoginView()
            } else {
                if prefersTabNavigation {
                    AppTabView()
                } else {
                    NavigationSplitView {
                        AppSidebarList(selection: $appRouter.selection)
                    } detail: {
                        AppDetailColumn(screen: appRouter.selection)
                    }
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
