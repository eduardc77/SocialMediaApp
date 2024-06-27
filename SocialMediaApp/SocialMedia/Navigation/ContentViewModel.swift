//
//  ContentViewModel.swift
//  SocialMedia
//

import Observation
import Combine
import FirebaseAuth
import SocialMediaNetwork

@Observable final class ContentViewModel {
    var userSession: FirebaseAuth.User?
    var loading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$loading.sink { [weak self] loading in
            self?.loading = loading
        }
        .store(in: &cancellables)
        
        AuthService.shared.$userSession.sink { [weak self] session in
            self?.userSession = session
        }
        .store(in: &cancellables)

    }
}
