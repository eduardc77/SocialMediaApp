//
//  ActivityView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct ActivityView: View {
    @StateObject private var model = ActivityViewModel()
    @EnvironmentObject private var router: ActivityViewRouter
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                Section(header: ActivityFilterView(currentFilter: $model.selectedFilter)) {
                    if model.filteredNotifications.isEmpty, !model.isLoading {
                        ContentUnavailableView(
                            "No Content",
                            systemImage: "doc.richtext",
                            description: Text(model.contentUnavailableText)
                        )
                    } else {
                        ForEach(model.filteredNotifications) { activityModel in
                            
                            switch activityModel.type {
                            case .follow, .like:
                                NavigationButton {
                                    router.push(activityModel.user)
                                } label: {
                                    ActivityRowView(router: router, model: activityModel)
                                }
                                
                            case .reply:
                                NavigationButton {
                                    if let post = activityModel.post {
                                        router.push(PostType.post(post))
                                    }
                                } label: {
                                    ActivityRowView(router: router, model: activityModel)
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
            if model.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    ActivityView()
}
