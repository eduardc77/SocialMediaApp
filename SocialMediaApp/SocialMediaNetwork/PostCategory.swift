
import SocialMediaUI

public enum PostCategory: String, Codable, TopFilter {
    case affirmations
    case art
    case beauty
    case fashion
    case celebrity
    case college
    case death
    case depression
    case faith
    case fitness
    case funny
    case future
    case health
    case heartbroken
    case leadership
    case love
    case marriage
    case men
    case money
    case motivation
    case overthinking
    case productivity
    case relationships
    case single
    case sleep
    case study
    case success
    case tips
    case women
    
    public var id: PostCategory { self }
    
    public var title: String {
        rawValue.capitalized
    }
    
    public var description: String {
        "This is a description of what the \(rawValue.capitalized) category is about."
    }
}

public extension PostCategory {
    var icon: String {
        switch self {
        case .affirmations:
            return "✨"
            
        case .art:
            return "🎨"
            
        case .beauty:
            return "🌸"
            
        case .fashion:
            return "👠"
            
        case .celebrity:
            return "⭐️"
            
        case .college:
            return "🎓"
            
        case .death:
            return "🪦"
            
        case .depression:
            return "🌧️"
            
        case .faith:
            return "🙏"
            
        case .fitness:
            return "👟"
            
        case .funny:
            return "😂"
            
        case .future:
            return "🔮"
            
        case .health:
            return "🫀"
            
        case .heartbroken:
            return "💔"
            
        case .leadership:
            return "🧑‍✈️"
            
        case .love:
            return "💌"
            
        case .marriage:
            return "💍"
            
        case .men:
            return "🚹"
            
        case .money:
            return "💰"
            
        case .motivation:
            return "🔥"
            
        case .overthinking:
            return "💭"
            
        case .productivity:
            return "🏗️"
            
        case .relationships:
            return "👥"
            
        case .single:
            return "👤"
            
        case .sleep:
            return "🛏️"
            
        case .study:
            return "📚"
            
        case .success:
            return "🏅"
            
        case .tips:
            return "💡"
            
        case .women:
            return "🚺"
        }
    }
}
