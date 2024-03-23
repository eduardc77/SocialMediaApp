//
//  PostActionSheetView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserPostActionSheetView: View {
    let post: Post
    var onDeleteHandler: (() -> Void)?
    
    @State private var isFollowed = false
    @Binding var selectedAction: UserPostActionSheetOptions?
    
    var body: some View {
        UserPostActionSheetRowView(option: .delete, selectedAction: $selectedAction, onDeleteHandler: onDeleteHandler)
    }
}

struct UserPostActionSheetRowView: View {
    let option: UserPostActionSheetOptions
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAction: UserPostActionSheetOptions?
    var onDeleteHandler: (() -> Void)?
    
    var body: some View {
        Button(role: .destructive) {
            selectedAction = option
            
            onDeleteHandler?()
            
            dismiss()
        } label: {
            Label(option.title, systemImage: option.iconName)
        }
    }
}

struct  UserPostActionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        UserPostActionSheetView(post: preview.post, selectedAction: .constant(.delete))
    }
}

struct PostActionSheetView: View {
    let post: Post
    var onDeleteHandler: (() -> Void)?
    
    @State private var isFollowed = false
    @Binding var selectedAction: PostActionSheetOptions?
    
    var body: some View {
        Group {
            if isFollowed {
                PostActionSheetRowView(option: .unfollow, selectedAction: $selectedAction)
            }
            
            PostActionSheetRowView(option: .mute, selectedAction: $selectedAction, onDeleteHandler: onDeleteHandler)
            
            PostActionSheetRowView(option: .report, selectedAction: $selectedAction)
                .foregroundStyle(.red)
            
            if !isFollowed {
                PostActionSheetRowView(option: .block, selectedAction: $selectedAction)
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            Task {
                if let user = post.user {
                    let isFollowed = await UserService.checkIfUserIsFollowed(user)
                    self.isFollowed = isFollowed
                }
            }
        }
    }
}

struct PostActionSheetRowView: View {
    let option: PostActionSheetOptions
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAction: PostActionSheetOptions?
    var onDeleteHandler: (() -> Void)?
    
    var body: some View {
        Button(role: .destructive) {
            selectedAction = option
            
            onDeleteHandler?()
            
            dismiss()
        } label: {
            Label(option.title, systemImage: option.iconName)
        }
    }
}

struct PostActionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PostActionSheetView(post: preview.post, selectedAction: .constant(.unfollow))
    }
}
