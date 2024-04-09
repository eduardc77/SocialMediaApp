
import Firebase

public extension Timestamp {
    
    func timestampString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self.dateValue(), relativeTo: Date())
    }
}
