import Foundation

enum URLType {
  case name(String)
  case url(URL)

  var url: URL? {
    switch self {
    case .name(let name):
        let gif = Bundle.main.url(forResource: name, withExtension: "gif")
        return gif
    case .url(let remoteURL):
        return remoteURL
    }
  }
}
