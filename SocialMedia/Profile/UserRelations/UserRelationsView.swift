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
    @Environment(\.dismiss) private var dismiss
    
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
                        SearchRow(user: user, thumbnailSize: 30)
                    }
                }
                .searchable(text: $searchText, prompt: "Search...")
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
#endif
    }
}

#Preview {
    UserRelationsView(user: Preview.user)
}
