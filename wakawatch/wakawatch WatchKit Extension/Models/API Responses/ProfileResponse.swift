import Foundation

struct ProfileResponse: Decodable {
    let data: UserData
    let created_at: String?
}

struct UserData: Decodable {
    let id: String
    let display_name: String?
    let photo: String?
    let website: String?
    let email: String?
    let city: LocationData?
}

struct LocationData: Decodable {
    let title: String?
}
