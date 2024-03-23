//
//  ContentView.swift
//  SocialMedia
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession == nil {
                LoginView()
            } else {
                AppTabView()
            }
        }
    }
}

#Preview {
    ContentView()
}
