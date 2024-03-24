//
//  ActivityView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ActivityView: View {
    @StateObject var viewModel = ActivityViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                    Section(header: ActivityFilterView(selectedFilter: $viewModel.selectedFilter)) {
                        ForEach(viewModel.filteredNotifications) { activityModel in
                            switch activityModel.type {
                            case .follow, .like:
                                NavigationLink(value: activityModel.user) {
                                    ActivityRowView(model: activityModel)
                                }
                            case .reply:
                                NavigationLink(value: activityModel.post) {
                                    ActivityRowView(model: activityModel)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.groupedBackground)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Activity")
            .navigationDestination(for: Post.self, destination: { post in
                PostDetailsView(post: post)
            })
            .navigationDestination(for: User.self, destination: { user in
                ProfileView(user: user)
            })
            .navigationDestination(for: PostCategory.self, destination: { category in
                PostCategoryDetailView(category: category)
            })
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
