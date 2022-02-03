struct LeaderboardResponse: Decodable {
    let current_user: LeaderboardUserData?
    let data: [LeaderboardData]
    let page: Int?
    let total_pages: Int?
}

struct LeaderboardUserData: Decodable {
    let rank: Int?
    let page: Int?
    let user: UserData?
}

struct LeaderboardData: Decodable {
    let rank: Int?
    let user: UserData?
}
