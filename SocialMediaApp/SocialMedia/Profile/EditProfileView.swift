//
//  EditProfileView.swift
//  SocialMedia
//

import SwiftUI
import Combine
import PhotosUI
import SocialMediaUI

struct EditProfileView: View {
    @State var model: CurrentUserProfileHeaderModel

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    EditableCircularProfileImage(model: model)
                    if let user = model.currentUser {
                        Text(user.fullName)
                            .font(.headline.bold())
                        
                        Text("Joined \(user.joinDate.dateValue().formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                             comment: "Variable is the calendar date when the person joined.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(.none)
                .listRowBackground(Color.clear)
                
                Section("Name") {
                    TextField("Display Name", text: $model.profileInputData.fullName)
#if DEBUG
                        .autocorrectionDisabled()
#endif
                        .textContentType(.name)
#if os(iOS)
                        .textInputAutocapitalization(.words)
#endif
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
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            try await model.updateUserData()
                        }
                        dismiss()
                    }
                    .disabled(!model.isProfileEdited)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditProfileView(model: CurrentUserProfileHeaderModel())
}
