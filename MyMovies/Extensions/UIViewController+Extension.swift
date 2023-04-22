//
//  UIViewController+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import CoreData
import SwiftUI

extension UIViewController {
    
    /// Dismiss keyboard when user tap anywhere outside input field
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - SwiftUI Preview
    /// Enable preview for UIKit
    /// source: https://fluffy.es/xcode-previews-uikit/
    @available(iOS 13, *)
    private struct Preview: UIViewControllerRepresentable {
        // this variable is used for injecting the current view controller
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}
