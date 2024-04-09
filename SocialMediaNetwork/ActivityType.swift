
public enum ActivityType: Int, CaseIterable, Identifiable, Codable {
    case like
    case reply
    case follow
    
    public var id: Int { return self.rawValue }
}
