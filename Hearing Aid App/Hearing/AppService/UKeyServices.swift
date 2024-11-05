import Foundation
import Security

final class UKeyServices: NSObject {
    
    private struct Keys {
        static let serviceName = Bundle.main.bundleIdentifier
        
        static let secMatchLimit = kSecMatchLimit as String
        static let secReturnData = kSecReturnData as String
        static let secValueData = kSecValueData as String
        static let secAttrAccessible = kSecAttrAccessible as String
        static let secClass = kSecClass as String
        static let secAttrService = kSecAttrService as String
        static let secAttrGeneric = kSecAttrGeneric as String
        static let secAttrAccount = kSecAttrAccount as String
    }
    
    //MARK: - Public Methods
    static func stringForKey(keyName: String) -> String? {
        let keychainData: NSData? = get(for: keyName)
        var stringValue: String?
        if let data = keychainData {
            stringValue = String(data: data as Data, encoding: .utf8)
        }
        return stringValue
    }
    
    @discardableResult
    static func setString(value: String, forKey keyName: String) -> Bool {
        if let data = value.data(using: .utf8) {
            return set(data as NSData, for: keyName)
        }
        return false
    }
    
    static func set(_ value: NSData, for keyName: String) -> Bool {
        var keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionaryForKey(keyName: keyName)
        keychainQueryDictionary[Keys.secValueData] = value
        keychainQueryDictionary[Keys.secAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value, for: keyName)
        } else {
            return false
        }
    }
    
    static func get(for keyName: String) -> NSData? {
        var keychainQueryDictionary = setupKeychainQueryDictionaryForKey(keyName: keyName)
        var result: AnyObject?
        keychainQueryDictionary[Keys.secMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[Keys.secReturnData] = kCFBooleanTrue
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQueryDictionary as CFDictionary, UnsafeMutablePointer($0))
        }
        return status == noErr ? result as? NSData : nil
    }
    
    @discardableResult
    static func remove(for keyName: String) -> Bool {
        let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionaryForKey(keyName: keyName)
        
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)
        if status == errSecSuccess {
            return true
        }
        return false
    }
    
    //MARK: - Private Methods
    private static func update(_ value: NSData, for keyName: String) -> Bool {
        let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionaryForKey(keyName: keyName)
        let updateDictionary = [Keys.secValueData: value]
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
        if status == errSecSuccess {
            return true
        }
        return false
    }
    
    private static func setupKeychainQueryDictionaryForKey(keyName: String) -> [String: Any] {
        var keychainQueryDictionary: [String: Any] = [Keys.secClass: kSecClassGenericPassword]
        keychainQueryDictionary[Keys.secAttrService] = Keys.serviceName
        let encodedIdentifier = keyName.data(using: String.Encoding.utf8)
        keychainQueryDictionary[Keys.secAttrGeneric] = encodedIdentifier
        keychainQueryDictionary[Keys.secAttrAccount] = encodedIdentifier
        return keychainQueryDictionary
    }
}
