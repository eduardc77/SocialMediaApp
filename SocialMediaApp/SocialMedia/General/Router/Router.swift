//
//  Router.swift
//  SocialMedia
//

import Foundation

public protocol Router {
    var path: [AnyHashable] { get }
    
    func push(_ screen: AnyHashable)
    func dismiss()
    func popToRoot()
}
