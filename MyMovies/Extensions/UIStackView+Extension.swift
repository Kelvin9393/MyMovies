//
//  UIStackView+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

extension UIStackView {
    
    /// Set margin to stackView
    /// - Parameter margins: The spacing to use when laying out content in the view.
    /// - Returns: Return the stackView
    @discardableResult public func withMargins(_ margins: UIEdgeInsets) -> UIStackView {
        layoutMargins = margins
        isLayoutMarginsRelativeArrangement = true
        return self
    }
    
    /// Set left padding to stackView
    /// - Parameter left: The left edge inset value.
    /// - Returns: Return the stackView
    @discardableResult public func padLeft(_ left: CGFloat) -> UIStackView {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins.left = left
        return self
    }
    
    /// Set top padding to stackView
    /// - Parameter top: The top edge inset value.
    /// - Returns: Return the stackView
    @discardableResult public func padTop(_ top: CGFloat) -> UIStackView {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins.top = top
        return self
    }
    
    /// Set bottom padding to stackView
    /// - Parameter bottom: The bottom edge inset value.
    /// - Returns: Return the stackView
    @discardableResult public func padBottom(_ bottom: CGFloat) -> UIStackView {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins.bottom = bottom
        return self
    }
    
    /// Set right padding to stackView
    /// - Parameter right: The right edge inset value.
    /// - Returns: Return the stackView
    @discardableResult public func padRight(_ right: CGFloat) -> UIStackView {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins.right = right
        return self
    }
}
