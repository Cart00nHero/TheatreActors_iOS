//
//  AppStorage.swift
//  GourmetLink
//
//  Created by YuCheng on 2024/9/10.
//

import Foundation
import Theatre
import Security

class AppDataStorage: Actor {
    private let storage = KeychainStorage.shared
    
    private func actStoreKeychain(_ data: KeychainData) -> Bool {
        return storage.store(account: data.account, value: data.value)
    }
    
    private func actRetrieveFromKeychain(_ account: String) -> String? {
        return storage.retrieve(account: account)
    }
    
    private func actDeleteFromKeychain(account: String) -> Bool {
        return storage.delete(account: account)
    }
    
    private func actStoreUserDefault(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func actRetrieveFromUserDefault<T>(_ key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }
    
    private func actDeleteFromUserDefault(_ key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return true
    }
    
    
}
extension AppDataStorage: StorageBehaviors {
    func storeKeychain(_ data: KeychainData) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actStoreKeychain(data)
        }
        return export
    }
    func retrieveFromKeychain(_ account: String) -> Teleport<String?> {
        let export = install(String?(nil))
        act { [unowned self] in
            export.portal = actRetrieveFromKeychain(account)
        }
        return export
    }
    func deleteFromKeychain(_ account: String) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actDeleteFromKeychain(account: account)
        }
        return export
    }
    func storeUserDefault(key: String, value: Any) {
        act { [unowned self] in
            actStoreUserDefault(key, value: value)
        }
    }
    func retrieveFromUserDefault<T>(key: String, type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actRetrieveFromUserDefault(key)
        }
        return export
    }
    func deleteFromUserDefault(key: String) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actDeleteFromUserDefault(key)
        }
        return export
    }
}
protocol StorageBehaviors {
    func storeKeychain(_ data: KeychainData) -> Teleport<Bool>
    func retrieveFromKeychain(_ account: String) -> Teleport<String?>
    func deleteFromKeychain(_ account: String) -> Teleport<Bool>
    func storeUserDefault(key: String, value: Any)
    func retrieveFromUserDefault<T>(key: String, type: T.Type) -> Teleport<T?>
    func deleteFromUserDefault(key: String) -> Teleport<Bool>
}

fileprivate class KeychainStorage {
    static let shared = KeychainStorage() // Singleton instance
    private let manager: Actor = Actor()
    private let service: String = Bundle.main.bundleIdentifier ?? "Cart00nHero8.GourmetLink"
    
    private init() {} // Private init to prevent instantiation
    
    /// Store data in the Keychain
    func store(account: String, value: String) -> Bool {
        let export = manager.install(false)
        manager.act { [unowned self] in
            let data = Data(value.utf8)
            
            // Define the query
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            
            // Delete any existing item before adding new one
            SecItemDelete(query as CFDictionary)
            
            // Add new item to the Keychain
            let status = SecItemAdd(query as CFDictionary, nil)
            export.portal = (status == errSecSuccess)
        }
        return export.portal
    }
    
    /// Retrieve data from the Keychain
    func retrieve(account: String) -> String? {
        let export = manager.install(String?(nil))
        manager.act { [unowned self] in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var item: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            
            if status == errSecSuccess {
                if let data = item as? Data {
                    export.portal = String(data: data, encoding: .utf8)
                    return
                }
            }
            export.portal = nil
        }
        return export.portal
    }
    
    /// Delete data from the Keychain
    func delete(account: String) -> Bool {
        let export = manager.install(false)
        manager.act { [unowned self] in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            export.portal = (status == errSecSuccess)
        }
        return export.portal
    }
}
struct KeychainData {
    let account: String
    let value: String
}
