//
//  AppService.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 13/12/2023.
//

import Foundation

protocol AppServiceProtocol: AnyObject {
    func setLastSelectedTab(tabIndex: Int)
    func getLastSelectedTab() -> Int
}

class AppService: AppServiceProtocol {
    @UserDefaultsManager(String(describing: UserDefaults.Key.lastSelectedTab), defaultValue: 0)
    private var lastSelectedTab: Int

    func getLastSelectedTab() -> Int {
        lastSelectedTab
    }

    func setLastSelectedTab(tabIndex: Int) {
        lastSelectedTab = tabIndex
    }
}
