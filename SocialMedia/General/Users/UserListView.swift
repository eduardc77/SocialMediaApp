//
//  UserListView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserListView: View {
    @ObservedObject var model: SearchViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(model.filteredUsers) { user in
                    NavigationLink(value: user) {
                        UserCell(model: model, user: user)
                            .padding(.leading)
                    }
                }
            }
            .navigationTitle("Search")
            .padding(.top)
        }
#if os(iOS)
        .searchable(text: $model.searchText, placement: .navigationBarDrawer)
#elseif os(macOS)
        .searchable(text: $model.searchText, placement: .automatic)
#endif
        .background(Color.groupedBackground)   
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(model: SearchViewModel())
    }
}
