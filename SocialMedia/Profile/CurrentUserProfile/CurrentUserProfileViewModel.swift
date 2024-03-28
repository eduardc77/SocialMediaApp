//
//  CurrentUserProfileViewModel.swift
//  SocialMedia
//

import Combine
import SwiftUI
import PhotosUI
import Firebase
import SocialMediaNetwork

@MainActor
final class CurrentUserProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var currentUser: SocialMediaNetwork.User?
    
    @Published var profileInputData = ProfileInputData()
    @Published var updatingProfile: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isProfileEdited: Bool {
        guard let user = currentUser else { return false }
        return profileInputData.fullName != user.fullName && !profileInputData.fullName.isEmpty ||
        profileInputData.aboutMe != user.aboutMe ||
        profileInputData.link != user.link ||
        profileInputData.privateProfile != user.privateProfile ||
        (profileInputData.profileImageURL != user.profileImageURL || newImageSet)
    }
    
    // Profile Image Properties
    @Published var imageState: ImageData.ImageState = .empty
    @Published var newImageSet: Bool = false
    
    // MARK: - Init
    
    init() {
        setupSubscribers()
    }
}

// MARK: - User Data

extension CurrentUserProfileViewModel {
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
        
        if profileInputData.profileImageURL != user.profileImageURL || newImageSet, case let .success(profileImageData) = imageState {
            try await updateProfileImage(profileImageData)
            data["profileImageURL"] = currentUser?.profileImageURL
        }
        try await FirestoreConstants.users.document(userID).updateData(data)
        newImageSet = false
        updatingProfile = false
    }
}

// MARK: - Subscribers

extension CurrentUserProfileViewModel {
    
    @MainActor
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }
        .store(in: &cancellables)
    }
}

// MARK: - Image Loading

private extension CurrentUserProfileViewModel {
    
    func updateProfileImage(_ imageData: Data) async throws {
        guard let userID = currentUser?.id, let imageUrl = try? await StorageService.uploadImage(imageData: imageData, type: .profile(userID: userID)) else { return }
        currentUser?.profileImageURL = imageUrl
        profileInputData.profileImageURL = imageUrl
    }
}
