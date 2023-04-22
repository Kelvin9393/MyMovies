//
//  BaseViewController.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Helpers
    
    func setupLayout() {
        
    }
    
    func setupUI() {
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    /// Check if viewController is released from memory to prevent memory leak
    deinit {
        print("deinit: \(self)")
    }
}
