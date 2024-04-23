
public struct UserInputData {
    public var email: String
    public var password: String
    public var fullName: String
    public var username: String
    
    public init(email: String = "anna.grace@gmail.com", password: String = "password", fullName: String = "", username: String = "") {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.username = username
    }
}
