//
//  CurrentUserProfileViewModel.swift
//  SocialMedia
//

import Observation
import Combine
import PhotosUI
import Firebase
import SocialMediaUI
import SocialMediaNetwork

@Observable public final class CurrentUserProfileHeaderModel {
    var currentUser: SocialMediaNetwork.User?
    
    var profileInputData = ProfileInputData()
    var updatingProfile: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isProfileEdited: Bool {
        guard let user = currentUser else { return false }
        return (profileInputData.fullName != user.fullName && !profileInputData.fullName.isEmpty) ||
        profileInputData.aboutMe != user.aboutMe ||
        profileInputData.link != user.link ||
        profileInputData.privateProfile != user.privateProfile ||
        (profileInputData.profileImageURL != user.profileImageURL ||
         imageData.newImageSet)
    }
    
    var imageData = ImageData()
    
    init() {
        setupSubscribers()
    }
}

extension CurrentUserProfileHeaderModel {
    func loadUserData() {
        guard let user = currentUser else { return }
        guard let currentUID = user.id else { return }
        
        Task {
            UserService.shared.currentUser?.stats = try await UserService.fetchUserStats(userID: currentUID)
        }
        
        profileInputData = ProfileInputData(fullName: user.fullName,
                                            username: user.username,
                                            aboutMe: user.aboutMe,
                                            link: user.link,
                                            profileImageURL: user.profileImageURL,
                                            privateProfile: user.privateProfile)
    }
    
    func updateUserData() async throws {
        guard let user = currentUser, let userID = user.id, isProfileEdited else { return }
        updatingProfile = true
        var data: [String: Any] = [:]
        
        if !profileInputData.fullName.isEmpty, profileInputData.fullName != user.fullName {
            currentUser?.fullName = profileInputData.fullName
            data["fullName"] = profileInputData.fullName
        }
        
        if profileInputData.aboutMe != user.aboutMe {
            currentUser?.aboutMe = profileInputData.aboutMe
            data["aboutMe"] = profileInputData.aboutMe
        }
        
        if profileInputData.link != user.link {
            currentUser?.link = profileInputData.link
            data["link"] = profileInputData.link
        }
        
        if profileInputData.privateProfile != user.privateProfile {
            currentUser?.privateProfile = profileInputData.privateProfile
            data["privateProfile"] = profileInputData.privateProfile
        }
        
        if profileInputData.profileImageURL != user.profileImageURL || imageData.newImageSet, case let .success(profileImageData) = imageData.imageState {
            try await updateProfileImage(profileImageData)
            data["profileImageURL"] = currentUser?.profileImageURL
        }
        try await FirestoreConstants.users.document(userID).updateData(data)

        updatingProfile = false
    }
}

extension CurrentUserProfileHeaderModel {
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }
        .store(in: &cancellables)
    }
}

private extension CurrentUserProfileHeaderModel {
    
    func updateProfileImage(_ imageData: Data) async throws {
        guard let userID = currentUser?.id, let imageUrl = try? await StorageService.uploadImage(imageData: imageData, type: .profile(userID: userID)) else { return }
        currentUser?.profileImageURL = imageUrl
        profileInputData.profileImageURL = imageUrl
    }
}
