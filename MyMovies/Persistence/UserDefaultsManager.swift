//
//  UserDefaultsManager.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 13/12/2023.
//

import Foundation

@propertyWrapper
struct UserDefaultsManager<T> {
    let key: String
    let defaultValue: T

    private let userDefaults = UserDefaults.standard

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
            userDefaults.synchronize()
        }
    }
}

extension UserDefaults {
    enum Key: String {
        case lastSelectedTab
    }
}
