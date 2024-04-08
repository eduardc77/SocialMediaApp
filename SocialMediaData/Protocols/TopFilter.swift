//
//  TopFilter.swift
//  SocialMedia
//

public protocol TopFilter: Hashable, CaseIterable, Identifiable {
    var title: String { get }
}
