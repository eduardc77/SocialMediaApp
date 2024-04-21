//
//  AppTabRouter.swift
//  SocialMedia
//

import Foundation

final class AppScreenRouter: ObservableObject {
    @Published var selection: AppScreen? = .home {
        willSet {
            if selection == newValue {
                tabReselected = true
            }
        }
    }
    
    /// Needed for going back to root view when tapping the already selected tab.
    @Published var tabReselected: Bool = false
    
    /// Set the urlString to open an external link.
    @Published var urlString: String?
}
