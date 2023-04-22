//
//  UIImageView+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import UIKit
import Nuke

extension UIImageView {
    
    /// 
    /// - Parameters:
    ///   - image: Image to be displayed
    ///   - contentMode: Image content mode, scaleAspectFill by default
    ///   - backgroundColor: The view’s background color.
    ///   - tintColor: A color used to tint template images in the view hierarchy.
    ///   - clipsToBounds: A Boolean value that determines whether subviews are confined to the bounds of the view.
    ///   - isHidden: A Boolean value that determines whether the view is hidden.
    convenience init(image: UIImage? = nil, contentMode: UIView.ContentMode = .scaleAspectFill, backgroundColor: UIColor = .clear, tintColor: UIColor? = nil, clipsToBounds: Bool = true, isHidden: Bool = false) {
        self.init(image: image?.withRenderingMode(tintColor != nil ? .alwaysTemplate : .alwaysOriginal))
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.isHidden = isHidden
    }
    
    /// Wrapper for loading image url using Nuke
    /// - Parameters:
    ///   - url: The image request url
    ///   - placeholder: Placeholder to be displayed when the image is loading . nil by default
    ///   - failureImage: Image to be displayd when request fails. nil by default
    ///   - contentModes: Image content mode, scaleAspectFill by default
    func loadImage(with url: URL, ofSize size: CGSize? = nil, placeholder: UIImage? = nil, failureImage: UIImage? = nil, contentModes: ImageLoadingOptions.ContentModes? = .init(success: .scaleAspectFill, failure: .scaleAspectFill, placeholder: .scaleAspectFill)) {
        
        var processors = [ImageProcessing]()
        if let size = size {
            processors.append(ImageProcessors.Resize(size: size))
        }
        
        let request = ImageRequest(url: url, processors: processors, priority: .high)
        let loadingOptions = ImageLoadingOptions(placeholder: placeholder,
                                                 transition: .fadeIn(duration: 0.1),
                                                 failureImage: failureImage,
                                                 failureImageTransition: .fadeIn(duration: 0.1),
                                                 contentModes: contentModes)
        
        Nuke.loadImage(with: request, options: loadingOptions, into: self, progress: nil)
    }
}
