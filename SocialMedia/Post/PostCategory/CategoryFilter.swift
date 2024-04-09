//
//  CategoryFilter.swift
//  SocialMedia
//

import SocialMediaUI

enum CategoryFilter: String, TopFilter {
    case hot
    case new
    
    var id: CategoryFilter { self }
    
    var title: String {
        rawValue.capitalized
    }
}
