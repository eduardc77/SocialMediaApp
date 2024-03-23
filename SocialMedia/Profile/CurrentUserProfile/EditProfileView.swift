//
//  EditProfileView.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var model: CurrentUserProfileViewModel
    @ObservedObject var imageData: ImageData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            if let user = model.currentUser {
                Form {
                    VStack {
                        EditableCircularProfileImage(model: model, imageData: imageData)
                        
                        Text(user.fullName)
                            .font(.headline.bold())
                        
                        Text("Joined \(user.joinDate.dateValue().formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                             comment: "Variable is the calendar date when the person joined.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(.none)
                    .listRowBackground(Color.clear)
                    
                    Section("Name") {
                        TextField("Display Name", text: $model.profileInputData.fullName)
#if os(iOS)
                            .textInputAutocapitalization(.words)
#endif
                            .disableAutocorrection(true)
                            .textContentType(.name)
                    }
                    
                    Section("Username") {
                        TextField("Username", text: $model.profileInputData.username)
                            .foregroundStyle(.secondary)
                            .disabled(true)
                    }
                    
                    Section("About Me") {
                        TextField("Write about you", text: $model.profileInputData.aboutMe, axis: .vertical)
                    }
                    Section("Link") {
                        TextField("Add Link", text: $model.profileInputData.link)
                    }
                    Section {
                        Toggle("Private profile", isOn: $model.profileInputData.privateProfile)
                    }
                }
                .formStyle(.grouped)
                .navigationTitle("Edit Profile")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            Task {
                                try await model.updateUserData()
                            }
                            dismiss()
                        }.disabled(!model.isProfileEdited)
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
#if !os(iOS)
                .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
#endif
                .onReceive(imageData.$newImageSet) { newValue in
                    model.newImageSet = newValue
                }
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(model: CurrentUserProfileViewModel(), imageData: ImageData())
    }
}
