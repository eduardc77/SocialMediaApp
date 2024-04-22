//
//  AppTabView.swift
//  SocialMedia
//

import SwiftUI

struct AppTabView: View {
    @EnvironmentObject private var appRouter: AppScreenRouter
    
    var body: some View {
        TabView(selection: $appRouter.selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem {
                        Image(systemName: screen.icon)
                            .environment(\.symbolVariants, appRouter.selection == screen ? .fill : .none)
                    }
            }
        }
        .onAppear {
            appRouter.selection = .home
        }
    }
}

#Preview {
    AppTabView()
        .environmentObject(AppScreenRouter())
        .environmentObject(ModalScreenRouter())
}
