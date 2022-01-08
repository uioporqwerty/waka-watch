import Foundation

struct User: Identifiable {
    var id = UUID()
    let displayName: String
    let photoUrl: URL?
    let website: URL?
    let createdDate: Date
    let location: String
}
