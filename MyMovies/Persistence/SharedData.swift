//
//  SharedData.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 12/01/2023.
//

import UIKit
import CoreData

final class SharedData {
    
    private static var shared: SharedData!
    
    private let userDefaults: UserDefaults
    private let dispatchGroup = DispatchGroup()
    
    let applicationDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    private enum UserDefaultsKey {
        static let lastSelectedTab = "lastSelectedTab"
    }

    static func shared(userDefaults: UserDefaults = .standard) -> SharedData {
        if shared == nil {
            shared = SharedData(userDefaults: userDefaults)
        }

        return shared
    }

    private init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - UserDefaults
    var lastSelectedTab: Int {
        get {
            return SharedData.shared().userDefaults.integer(forKey: UserDefaultsKey.lastSelectedTab)
        }
        
        set {
            SharedData.shared().userDefaults.set(newValue, forKey: UserDefaultsKey.lastSelectedTab)
        }
    }
    
}
