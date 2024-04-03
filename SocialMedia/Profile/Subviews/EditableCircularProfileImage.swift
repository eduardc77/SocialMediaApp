//
//  EditableCircularProfileImage.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI

struct EditableCircularProfileImage: View {
    @ObservedObject var model: CurrentUserProfileHeaderModel
    @ObservedObject var imageData: ImageData
    var size: ImageSize = .xLarge
    
    var body: some View {
        PhotosPicker(selection: $imageData.imageSelection,
                     matching: .images,
                     photoLibrary: .shared()) {
            Group {
                if imageData.imageSelection != nil {
                    SelectedPhotoPickerImage(imageState: imageData.imageState, size: size, contentMode: .fill)
                        .clipShape(Circle())
                } else {
                    CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL, size: size)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundStyle(.tint)
            }
        }
        .buttonStyle(.borderless)
        .onDisappear {
            imageData.imageSelection = nil
            imageData.newImageSet = false
        }
    }
}
