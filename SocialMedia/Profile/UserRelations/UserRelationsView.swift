//
//  UserRelationsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserRelationsView: View {
    @StateObject var viewModel: UserRelationsViewModel
    @State private var searchText = ""
    @Namespace var animation
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: UserRelationsViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            // filter view
            HStack {
                ForEach(UserRelationType.allCases) { type in
                    VStack {
                        Text(type.title)
                        
                        if viewModel.selectedFilter == type {
                            Rectangle()
                                .foregroundStyle(Color.primary)
                                .frame(width: 180, height: 1)
                                .matchedGeometryEffect(id: "item", in: animation)
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 180, height: 1)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.selectedFilter = type
                        }
                    }
                }
            }
                        
            ScrollView {
                LazyVStack {
                    Text(viewModel.currentStatString)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .padding(4)
                    
                    ForEach(viewModel.users) { user in
                        UserCell(model: SearchViewModel(), user: user)
                    }
                }
                .searchable(text: $searchText, prompt: "Search...")
            }
        }
        .padding()
    }
}

struct UserRelationsView_Previews: PreviewProvider {
    static var previews: some View {
        UserRelationsView(user: preview.user)
    }
}
