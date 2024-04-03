//
//  AppTabView.swift
//  SocialMedia
//

import SwiftUI

struct AppTabView: View {
    @ObservedObject var appRouter: AppTabRouter

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
    }
}

#Preview {
    AppTabView(appRouter: AppTabRouter())
}
