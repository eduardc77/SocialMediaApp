//
//  TabBarModel.swift
//  SocialMedia
//

import SwiftUI

@MainActor
class TabBarModel<Tab>: ObservableObject where Tab: Hashable {
    
    private(set) var tabs: [Tab] = []
    var labels: [Tab: ContainerTabBar<Tab>.CustomLabel] = [:]
    
    func register(tab: Tab, @ViewBuilder label: @escaping ContainerTabBar<Tab>.CustomLabel) {
        if !tabs.contains(tab) {
            tabs.append(tab)
        }
        labels[tab] = label
    }
}
