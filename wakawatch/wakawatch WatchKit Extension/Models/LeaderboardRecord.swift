import Foundation

struct LeaderboardRecord: Identifiable {
    let id: UUID
    let rank: Int
    let user: User
}

extension LeaderboardRecord {
    static let mockLeaderboard = [
        LeaderboardRecord(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b31")!, rank: 1, user: User(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b31")!, displayName: "Nitish Sachar", photoUrl: URL(string: "https://wakatime.com/photo/63682d84-94b1-435b-82bb-a31eccb45b31"), website: URL(string: "https://nybble.app"), createdDate: Date(), location: "")),
        LeaderboardRecord(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b32")!, rank: 2, user: User(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b32")!, displayName: "dlee", photoUrl: nil, website: nil, createdDate: Date(), location: "Los Angeles, CA")),
        LeaderboardRecord(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b33")!, rank: 3, user: User(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b33")!, displayName: "Anonymous User", photoUrl: nil, website: nil, createdDate: Date(), location: "Irvine, CA")),
        LeaderboardRecord(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b34")!, rank: 4, user: User(id: UUID(uuidString: "63682d84-94b1-435b-82bb-a31eccb45b34")!, displayName: "Anonymous User", photoUrl: nil, website: nil, createdDate: Date(), location: "Irvine, CA"))
    ]
}
