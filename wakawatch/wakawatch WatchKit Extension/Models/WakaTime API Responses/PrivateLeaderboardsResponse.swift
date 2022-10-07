struct PrivateLeaderboardsResponse: Decodable {
    let data: [PrivateLeaderboardData]
    let total_pages: Int?
}

struct PrivateLeaderboardData: Decodable {
    let id: String
    let name: String
    let members_count: Int
}
