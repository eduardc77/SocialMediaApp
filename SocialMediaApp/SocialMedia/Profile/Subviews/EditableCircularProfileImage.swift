//
//  EditableCircularProfileImage.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI
import SocialMediaUI

struct EditableCircularProfileImage: View {
    @State var model: CurrentUserProfileHeaderModel

    var size: ImageSize = .xLarge
    
    var body: some View {
        PhotosPicker(selection: $model.imageData.imageSelection,
                     matching: .images,
                     photoLibrary: .shared()) {
            Group {
                if model.imageData.imageSelection != nil {
                    SelectedPhotoPickerImage(imageState: model.imageData.imageState, size: size, contentMode: .fill)
                        .clipShape(Circle())
                } else {
                    CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL, size: size)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 24))
                    .foregroundStyle(.tint)
            }
        }
        .buttonStyle(.borderless)
        .onDisappear {
            model.imageData.imageSelection = nil
        }
    }
}
