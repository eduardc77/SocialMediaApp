//
//  ActivityView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @EnvironmentObject private var router: ActivityViewRouter
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                Section(header: ActivityFilterView(selectedFilter: $viewModel.selectedFilter)) {
                    ForEach(viewModel.filteredNotifications) { activityModel in
                        switch activityModel.type {
                        case .follow, .like:
                            NavigationLink {
                                ActivityRowView(router: router, model: activityModel)
                            } action: {
                                router.push(activityModel.user)
                            }
                        case .reply:
                            NavigationLink {
                                ActivityRowView(router: router, model: activityModel)
                            } action: {
                                if let post = activityModel.post {
                                    router.push(PostType.post(post))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Activity")
        .background(Color.groupedBackground)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
