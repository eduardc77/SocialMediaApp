//
//  UserContentListView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserContentListView: View {
    var router: any Router
    @Binding var selectedFilter: ProfilePostFilter
    @StateObject var model: UserContentListViewModel
    @Namespace var animation
    
    init(router: any Router, selectedFilter: Binding<ProfilePostFilter>, user: User) {
        self.router = router
        self._selectedFilter = selectedFilter
        self._model = StateObject(wrappedValue: UserContentListViewModel(user: user))
    }
    
    var body: some View {
        LazyVStack(pinnedViews: .sectionHeaders) {
            Section(header: profileFilter) {
                LazyVStack {
                    if selectedFilter == .posts {
                        if model.posts.isEmpty {
                            Text(model.noContentText(filter: .posts))
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        } else {
                            PostGrid(router: router, postGridType: .posts(model.posts),
                                     isLoading: .constant(false),
                                     loadNewPage: {})
                                .transition(.move(edge: .leading))
                        }
                    } else {
                        if model.replies.isEmpty {
                            Text(model.noContentText(filter: .replies))
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        } else {
                            ForEach(model.replies) { reply in
                                ReplyRow(reply: reply)
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
            router: ProfileViewRouter(), selectedFilter: .constant(.posts),
            user: preview.user
        )
    }
}
