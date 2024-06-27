//
//  ActivityView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct ActivityView: View {
    @State private var model = ActivityViewModel()
    @Environment(ViewRouter.self) private var router
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section(header: ActivityFilterView(currentFilter: $model.selectedFilter)) {
                    if model.filteredNotifications.isEmpty, !model.loading {
                        ContentUnavailableView(
                            "No Content",
                            systemImage: "doc.richtext",
                            description: Text(model.contentUnavailableText)
                        )
                    } else {
                        ForEach(model.filteredNotifications) { activityModel in
                            switch activityModel.type {
                            case .like, .follow:
                                NavigationButton {
                                    if let user = activityModel.user {
                                        router.push(user)
                                    }
                                } label: {
                                    ActivityRowView(router: router, activity: activityModel)
                                }
                                
                            case .reply:
                                NavigationButton {
                                    if let post = activityModel.post {
                                        router.push(PostType.post(post))
                                    }
                                } label: {
                                    ActivityRowView(router: router, activity: activityModel)
                                }
                            }
                            
                            Divider()
                                .padding(.leading)
                                .padding(.leading, 10)
                                .padding(.leading, ImageSize.small.value.width)
                        }
                    }
                }
            }
        }
        .onChange(of: model.selectedFilter) { oldValue, newValue in
            guard oldValue != newValue else { return }
            model.setupFilteredNotifications()
        }
        .navigationTitle("Activity")
        .overlay {
            if model.loading {
                ProgressView()
            }
        }
        .task {
            await model.refresh()
        }
        .refreshable {
            await model.refresh()
        }
    }
}

#Preview {
    ActivityView()
        .environment(ModalScreenRouter())
        .environment(ViewRouter())
}
