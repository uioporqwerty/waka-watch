import Foundation

struct AccessTokenResponse: Decodable {
    let access_token: String
    let expires_at: String
    let refresh_token: String
}
