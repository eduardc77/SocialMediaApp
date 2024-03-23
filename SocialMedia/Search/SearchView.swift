//
//  SearchView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchView: View {
    @State private var searchText = ""
    @StateObject var model = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                UserListView(model: model)
                    .navigationDestination(for: User.self) { user in
                        ProfileView(user: user)
                    }
            }
            .overlay {
                if model.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
