//
//  BaseTabBarController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
//        selectedIndex = SharedData.shared().lastSelectedTab
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = SharedData.shared().lastSelectedTab
    }
    
}

// MARK: - UITabBarControllerDelegate
extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController) {
            SharedData.shared().lastSelectedTab = index
        }
        return true
    }
}
