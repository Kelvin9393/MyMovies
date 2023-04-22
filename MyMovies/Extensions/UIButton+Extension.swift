//
//  UIButton+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

extension UIButton {
    
    /// Title UIButton creation method
    /// - Parameters:
    ///   - configuration: The configuration for the button’s appearance.
    ///   - title: Sets the title to use for nomal state.
    ///   - titleColor: Sets the color of the title to use for the normal state.
    ///   - font: The font of the text.
    ///   - backgroundColor: The button’s background color.
    ///   - isEnabled: A Boolean value indicating whether the control is in the enabled state.
    ///   - isHidden: A Boolean value that determines whether the button is hidden.
    ///   - target: Associates a target object with the control.
    ///   - action: Associates an action method with the control.
    convenience init(configuration: UIButton.Configuration? = nil, title: String, titleColor: UIColor = .black, font: UIFont = .systemFont(ofSize: 14), backgroundColor: UIColor = .clear, isEnabled: Bool = true, isHidden: Bool = false, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        self.configuration = configuration
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        
        self.backgroundColor = backgroundColor
        if let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
    }
    
    /// Image UIButton creation method
    /// - Parameters:
    ///   - configuration: The configuration for the button’s appearance.
    ///   - image: Sets the image to use for nomal state.
    ///   - backgroundColor: The button’s background color.
    ///   - tintColor: The tint color to apply to the button title and image.
    ///   - isEnabled: A Boolean value indicating whether the control is in the enabled state.
    ///   - isHidden: A Boolean value that determines whether the button is hidden.
    ///   - target: Associates a target object with the control.
    ///   - action: Associates an action method with the control.
    convenience init(configuration: UIButton.Configuration? = nil, image: UIImage, backgroundColor: UIColor? = nil, tintColor: UIColor? = nil, isEnabled: Bool = true, isHidden: Bool = false, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        self.configuration = configuration
        if tintColor == nil {
            setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = tintColor
        }
        self.backgroundColor = backgroundColor
        imageView?.contentMode = .scaleAspectFit
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        
        if let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
    }
}
