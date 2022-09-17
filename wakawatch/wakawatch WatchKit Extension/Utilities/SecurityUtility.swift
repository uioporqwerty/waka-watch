import Foundation

final class SecurityUtility {
    static func secureRandomStateCode() -> String {
        let count = MemoryLayout<Int>.size
        var bytes = [Int8](repeating: 0, count: count)

        let status = SecRandomCopyBytes(
            kSecRandomDefault,
            count,
            &bytes
        )
        
        let secureInt = bytes.withUnsafeBytes { pointer in
            return pointer.load(as: Int.self)
        }

        return String(secureInt)
    }
}
