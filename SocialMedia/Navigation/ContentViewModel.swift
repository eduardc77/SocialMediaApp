//
//  ContentViewModel.swift
//  SocialMedia
//

import Combine
import FirebaseAuth
import SocialMediaNetwork

final class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: SocialMediaNetwork.User?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        isLoading = true
        AuthService.shared.$userSession.sink { [weak self] session in
            self?.userSession = session
        }
        .store(in: &cancellables)
        
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
            if self?.currentUser != nil || self?.userSession == nil {
                self?.isLoading = false
            }
        }
        .store(in: &cancellables)
    }
}
