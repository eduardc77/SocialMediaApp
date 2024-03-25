//
//  PostEditorView.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI

struct PostEditorView: View {
    @StateObject var model = PostEditorViewModel()
    @StateObject var imageData = ImageData()
    
    @EnvironmentObject private var tabRouter: AppRouter
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
           ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        CircularProfileImageView(profileImageURL: model.user?.profileImageURL, size: .small)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(model.user?.fullName ?? "")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                
                                Text(model.user?.username ?? "")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                        
                        if !model.caption.isEmpty {
                            Button {
                                model.caption = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    TextField("Write a post...", text: $model.caption, axis: .vertical)
                        .autocorrectionDisabled()
                        .font(.footnote)
                    
                    SelectedPhotoPickerImage(imageState: imageData.imageState, size: .custom(height: 300))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                withAnimation {
                                    imageData.imageState = .empty
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundStyle(Color.white)
                            }
                            .padding()
                        }
                    
                    HStack {
                        PhotosPicker(selection: $imageData.imageSelection, matching: .images) {
                            Image(systemName: "photo.badge.plus")
                                .font(.title3)
                        }
                        Spacer()
                        
                        categoryPicker
                    }
                }
                .padding(10)
                .background(Color.secondaryGroupedBackground.clipShape(.rect(cornerRadius: 8)))
                
                Spacer()
            }
            .padding(10)
            .background(Color.groupedBackground)
            .toolbar {
#if !os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                }
#endif
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            try await model.uploadPost()
                            tabRouter.selection = .home
#if !os(macOS)
                            dismiss()
#endif
                        }
                    }
                    .opacity(model.caption.isEmpty ? 0.5 : 1.0)
                    .disabled(model.caption.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationTitle("New Post")
        }
        .onReceive(imageData.$imageState) { newValue in
            model.imageState = newValue
        }
    }
}

// MARK: - Subviews

private extension PostEditorView {
    
    var categoryPicker: some View {
        Menu {
            Picker(selection: $model.category) {
                ForEach(model.postCategories, id: \.self) { category in
                    Text(category.icon + " " + category.rawValue.capitalized)
                        .font(.footnote)
                    
                }
            } label: {}
        } label: {
            HStack {
                Text(model.pickerTitle)
                    .foregroundStyle(Color.primary)
                    .font(.subheadline)
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(settings.theme.color)
                    .font(.footnote)
            }
            .fontWeight(.medium)
        }
        .padding(6)
        .background(in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        .backgroundStyle(.regularMaterial)
        .contentShape(.rect)
#if os(macOS)
        .frame(maxWidth: 200)
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
#endif
    }
    
}
struct PostEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PostEditorView()
    }
}
