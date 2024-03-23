//
//  ActivityBadgeView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ActivityBadgeView: View {
    let type: ActivityType
    
    private var badgeColor: Color {
        switch type {
            case .like: return .pink
            case .follow: return .indigo
            case .reply: return .blue
        }
    }
    
    private var badgeImageName: String {
        switch type {
            case .like: return "heart.fill"
            case .follow: return "person.fill"
            case .reply: return "arrowshape.turn.up.backward.fill"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.groupedBackground)
            
            ZStack {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 18, height: 18)
                
                
                Image(systemName: badgeImageName)
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
        }
    }
}

struct ActivityBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityBadgeView(type: .follow)
    }
}
