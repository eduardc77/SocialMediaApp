//
//  ContentViewModel.swift
//  SocialMedia
//

import Combine
import FirebaseAuth
import SocialMediaNetwork

final class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var loading: Bool = false
    
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
