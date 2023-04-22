//
//  UILabel+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

extension UILabel {
    
    /// UILabel creation method
    /// - Parameters:
    ///   - text: The text that the label displays, nil by default.
    ///   - font: The font of the text, nil by default.
    ///   - textColor: The color of the text, default by UIColor.label
    ///   - textAlignment: The technique for aligning the text, default by NSTextAlignment.left.
    ///   - numberOfLines: The maximum number of lines for rendering text, default line number is 1.
    ///   - lineBreakMode: The technique for wrapping and truncating the label’s text, default is byTruncatingTail.
    ///   - adjustsFontSizeToFitWidth: A Boolean value that determines whether the label reduces the text’s font size to fit the title string into the label’s bounding rectangle, default is false.
    ///   - backgroundColor: The label’s background color.
    ///   - isHidden: A Boolean value that determines whether the UILabel is hidden.
    convenience init(text: String? = nil, font: UIFont? = nil, textColor: UIColor = .label, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1, lineBreakMode: NSLineBreakMode = .byTruncatingTail, adjustsFontSizeToFitWidth: Bool = false, backgroundColor: UIColor = .clear, isHidden: Bool = false) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.backgroundColor = backgroundColor
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.isHidden = isHidden
    }
}
