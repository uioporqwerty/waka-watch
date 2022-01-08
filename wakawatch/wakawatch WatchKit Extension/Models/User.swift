import Foundation

struct User: Identifiable {
    var id: UUID
    let displayName: String
    let photoUrl: URL?
    let website: URL?
    let createdDate: Date
    let location: String
}

extension User {
    static let mockUsers = [
        User(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b31")!,
             displayName: "Nitish Sachar",
             photoUrl: URL(string: "https://wakatime.com/photo/63682d84-94b1-435b-82bb-a31eccb45b31"),
             website: URL(string: "https://nybble.app"),
             createdDate: Date(),
             location: "")
    ]
}
