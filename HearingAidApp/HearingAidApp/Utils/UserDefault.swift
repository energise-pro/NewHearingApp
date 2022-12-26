//
//  UserDefault.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 13.12.2022.
//

import SwiftUI

@propertyWrapper
struct UserDefault<Value>: DynamicProperty {
    
    // MARK: - Private Properties
    private let get: () -> Value
    private let set: (Value) -> Void
    
    var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
    
    // MARK: - Initializers
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Bool {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Int {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Double {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == String {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == URL {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Data {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }
    
    private init(defaultValue: Value, key: String, store: UserDefaults) {
        get = {
            store.value(forKey: key) as? Value ?? defaultValue }
        set = { store.set($0, forKey: key) }
    }
}
