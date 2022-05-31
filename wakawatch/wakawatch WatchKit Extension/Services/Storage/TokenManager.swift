import Foundation

class TokenManager {
    private var keychainServicesService: KeychainServicesService

    init(keychainService: KeychainServicesService) {
        self.keychainServicesService = keychainService
    }

    func setAccessToken(_ token: String) {
        try? self.keychainServicesService.set(data: Data(token.utf8), key: KeychainKeys.accessToken)
    }

    func getAccessToken() -> String {
        guard let token = try? String(decoding: self.keychainServicesService.get(key: KeychainKeys.accessToken),
                                      as: UTF8.self) else {
            return ""
        }
        return token
    }

    func setRefreshToken(_ refreshToken: String) {
        try? self.keychainServicesService.set(data: Data(refreshToken.utf8), key: KeychainKeys.refreshToken)
    }

    func getRefreshToken() -> String {
        guard let token = try? String(decoding: self.keychainServicesService.get(key: KeychainKeys.refreshToken),
                                      as: UTF8.self) else {
            return ""
        }
        return token
    }

    func removeAll() {
        try? self.keychainServicesService.remove(key: KeychainKeys.accessToken)
        try? self.keychainServicesService.remove(key: KeychainKeys.refreshToken)
    }
}
