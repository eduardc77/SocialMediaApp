//
//  AppDetailColumn.swift
//  SocialMedia
//

import SwiftUI

struct AppDetailColumn: View {
    var screen: AppScreen?

    var body: some View {
        Group {
            if let screen {
                screen.destination
            } else {
                ContentUnavailableView("Select a screen", systemImage: "list.clipboard.fill", description: Text("Pick something from the list."))
            }
        }
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        #endif
    }
}

#Preview {
    AppDetailColumn()
}
