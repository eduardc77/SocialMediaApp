//
//  ContentView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ContentView: View {
    @State private var model = ContentViewModel()
    @EnvironmentObject private var appRouter: AppScreenRouter
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if model.loading {
            ProgressView()
        } else if model.userSession == nil {
            LoginView()
        } else {
            if prefersTabNavigation {
                AppTabView()
            } else {
                NavigationSplitView {
                    AppSidebarList()
                } detail: {
                    AppDetailColumn(screen: appRouter.selection)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
