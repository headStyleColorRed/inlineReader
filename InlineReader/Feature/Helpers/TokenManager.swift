import Foundation

class TokenManager {
    private static let tokenKey = "auth_token"

    static func storeToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    static func loadToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    static func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
