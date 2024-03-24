//
//  UserContentListView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserContentListView: View {
    @Binding var selectedFilter: ProfilePostFilter
    @StateObject var viewModel: UserContentListViewModel
    @Namespace var animation
    
    init(selectedFilter: Binding<ProfilePostFilter>, user: User) {
        self._selectedFilter = selectedFilter
        self._viewModel = StateObject(wrappedValue: UserContentListViewModel(user: user))
    }
    
    var body: some View {
        LazyVStack(pinnedViews: .sectionHeaders) {
            Section(header: profileFilter) {
                LazyVStack {
                    if selectedFilter == .posts {
                        if viewModel.posts.isEmpty {
                            Text(viewModel.noContentText(filter: .posts))
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        } else {
                            PostGrid(postGridType: .posts(viewModel.posts), isLoading: .constant(false), fetchNewPage: {})
                                .transition(.move(edge: .leading))
                        }
                    } else {
                        if viewModel.replies.isEmpty {
                            Text(viewModel.noContentText(filter: .replies))
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        } else {
                            ForEach(viewModel.replies) { reply in
                                PostReplyRow(reply: reply)
                            }
                            .padding(.horizontal, 10)
                            .transition(.move(edge: .trailing))
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    var profileFilter: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach([ProfilePostFilter.posts, ProfilePostFilter.replies], id: \.self) { filter in
                    profileFilterItem(for: filter)
                        .id(filter)
                        .frame(maxWidth: .infinity)
                }
            }
            Divider()
        }
        .background(Color.groupedBackground)
    }
    
    func profileFilterItem(for filter: ProfilePostFilter) -> some View {
        Button {
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(.footnote.weight(.semibold))
                .padding(.vertical, 10)
                .foregroundStyle(selectedFilter == filter ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    if selectedFilter == filter {
                        Rectangle()
                            .fill(.primary)
                            .frame(height: 1)
                            .matchedGeometryEffect(id: "item", in: animation)
                            .padding(.horizontal)
                        
                    }
                }
        }
    }
}

struct UserContentListView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentListView(
            selectedFilter: .constant(.posts),
            user: preview.user
        )
    }
}
