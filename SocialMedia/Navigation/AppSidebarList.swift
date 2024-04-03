//
//  AppSidebarList.swift
//  SocialMedia
//

import SwiftUI

struct AppSidebarList: View {
    @Binding var selection: AppScreen?
    
    var body: some View {
        List(AppScreen.allCases, selection: $selection) { screen in
            SwiftUI.NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("Social Media")
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList(selection: .constant(.home))
    } detail: {
        Text(verbatim: "Check out that sidebar!")
    }
}
