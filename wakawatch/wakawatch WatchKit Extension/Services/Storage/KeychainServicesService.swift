import SwiftUI

class KeychainServicesService {
    private let service = "app.wakawatch"
    private let logManager: LogManager

    init(logManager: LogManager) {
        self.logManager = logManager
    }

    func set(data: Data,
             key: String
             ) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: self.service as AnyObject,
            kSecAttrAccount as String: key as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: data as AnyObject
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            self.logManager.reportError(KeychainError.duplicateItem)
            throw KeychainError.duplicateItem
        }

        guard status == errSecSuccess else {
            self.logManager.reportError(KeychainError.unexpectedStatus(status))
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func get(key: String
    ) throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: self.service as AnyObject,
            kSecAttrAccount as String: key as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        guard status != errSecItemNotFound else {
            self.logManager.reportError(KeychainError.itemNotFound)
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            self.logManager.reportError(KeychainError.unexpectedStatus(status))
            throw KeychainError.unexpectedStatus(status)
        }

        guard let item = itemCopy as? Data else {
            self.logManager.reportError(KeychainError.invalidItemFormat)
            throw KeychainError.invalidItemFormat
        }

        return item
    }

    func remove(key: String) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: self.service as AnyObject,
            kSecAttrAccount as String: key as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            self.logManager.reportError(KeychainError.unexpectedStatus(status))
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
