//
//  AppSidebarList.swift
//  SocialMedia
//

import SwiftUI

struct AppSidebarList: View {
    @EnvironmentObject private var appRouter: AppScreenRouter
    
    var body: some View {
        List(AppScreen.allCases, selection: $appRouter.selection) { screen in
            NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("Social Media")
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList()
    } detail: {
        Text(verbatim: "Check out that sidebar!")
    }
    .environment(ModalScreenRouter())
    .environmentObject(AppScreenRouter())
}
