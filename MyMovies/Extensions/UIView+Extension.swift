//
//  UIView+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit
import SwiftUI

enum Anchor {
    case top(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case leading(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case bottom(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case trailing(_ trailing: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case height(_ constant: CGFloat)
    case width(_ constant: CGFloat)
}

extension UIView {
    
    
    /// View initializer with background color
    /// - Parameter backgroundColor: The view’s background color.
    convenience init(backgroundColor: UIColor? = .clear) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    // MARK: - Layout
    @discardableResult
    func anchor(_ anchors: Anchor...) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchors.forEach { anchor in
            switch anchor {
            case .top(let anchor, let constant):
                anchoredConstraints.top = topAnchor.constraint(equalTo: anchor, constant: constant)
            case .leading(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(equalTo: anchor, constant: constant)
            case .bottom(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
            case .trailing(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: anchor, constant: -constant)
            case .height(let constant):
                if constant > 0 {
                    anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
                }
            case .width(let constant):
                if constant > 0 {
                    anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
                }
            }
        }
        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach {
            $0?.isActive = true
         }
        return anchoredConstraints
    }
    
    /// Add view as subView and layout to a superview, by using autoLayout
    /// - Parameter padding: Padding between added subview and superview
    /// - Returns: Layout constraints for adding the subview using autoLayout
    @discardableResult func fillSuperview(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        
        guard let superviewTopAnchor = superview?.topAnchor,
              let superviewBottomAnchor = superview?.bottomAnchor,
              let superviewLeadingAnchor = superview?.leadingAnchor,
              let superviewTrailingAnchor = superview?.trailingAnchor else {
            return anchoredConstraints
        }
        
        return anchor(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
    }
    
    /// Set the view to be same size with another view
    /// - Parameter view: The view where current view want to be same size with.
    /// - Returns: Width and height constraints for anchoring the view
    @discardableResult func anchorSize(to view: UIView) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        anchoredConstraints.width = widthAnchor.constraint(equalTo: view.widthAnchor)//.isActive = true
        anchoredConstraints.height = heightAnchor.constraint(equalTo: view.heightAnchor)//.isActive = true
        
        [anchoredConstraints.width,
         anchoredConstraints.height].forEach {
            $0?.isActive = true
         }
        return anchoredConstraints
    }
    
    /// Center subview in superView
    /// - Parameter size: Set designated size for subview
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero, widthAnchor: NSLayoutDimension? = nil, widthMultiplier: CGFloat = 1, heightAnchor: NSLayoutDimension? = nil, heightMultiplier: CGFloat = 1, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)//.isActive = true
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)//.isActive = true
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)//.isActive = true
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)//.isActive = true
        }
        
        if size.width != 0 {
            anchoredConstraints.width = self.widthAnchor.constraint(equalToConstant: size.width)//.isActive = true
        }
        
        if size.height != 0 {
            anchoredConstraints.height = self.heightAnchor.constraint(equalToConstant: size.height)//.isActive = true
        }
        
        if let widthAnchor = widthAnchor {
            if size.width != 0 {
                fatalError("WidthAnchor Conflict: Remove size parameter or set size's width to 0")
            }
            anchoredConstraints.width = self.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier)//.isActive = true
        }
        
        if let heightAnchor = heightAnchor {
            if size.width != 0 {
                fatalError("HeightAnchor Conflict: Remove size parameter or set size's height to 0")
            }
            anchoredConstraints.height = self.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier)//.isActive = true
        }
        
        if let centerX = centerX {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: centerX)//.isActive = true
        }
        
        if let centerY = centerY {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: centerY)//.isActive = true
        }
        
        [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom, anchoredConstraints.trailing, anchoredConstraints.width, anchoredConstraints.height, anchoredConstraints.centerX, anchoredConstraints.centerY].forEach{ $0?.isActive = true }
        
        return anchoredConstraints
    }
    
    // MARK: - Stacking
    
    private func _stack(_ axis: NSLayoutConstraint.Axis = .vertical, views: [UIView], spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        addSubview(stackView)
        stackView.fillSuperview()
        return stackView
    }
    
    /// Vertical stackView
    /// - Parameters:
    ///   - views: The views to be arranged by the stack view.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views.
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis.
    ///   - distribution: The distribution of the arranged views along the stack view’s axis.
    /// - Returns: StackView that contains all the views
    @discardableResult func vstack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        return _stack(.vertical, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    /// Horizontal stackView
    /// - Parameters:
    ///   - views: The views to be arranged by the stack view.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views.
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis.
    ///   - distribution: The distribution of the arranged views along the stack view’s axis.
    /// - Returns: StackView that contains all the views
    @discardableResult func hstack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        return _stack(.horizontal, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    /// Set size in width and height for the view
    /// - Parameter size: The value of designated width and height in CGSize
    /// - Returns: View where the size is set
    @discardableResult public func withSize<T: UIView>(_ size: CGSize) -> T {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        return self as! T
    }
    
    /// Set height for the view
    /// - Parameter height: The value of the designated height
    /// - Returns: View where the size is set
    @discardableResult public func withHeight(_ height: CGFloat) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    /// Set width for the view
    /// - Parameter width: The value of the designated width
    /// - Returns: View where the size is set
    @discardableResult public func withWidth(_ width: CGFloat) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
}

struct AnchoredConstraints {
    var top, leading, bottom, trailing, width, height, centerX, centerY: NSLayoutConstraint?
}
