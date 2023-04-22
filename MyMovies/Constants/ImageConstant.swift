//
//  ImageConstant.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 08/01/2023.
//

import UIKit

extension UIImage {
    static let isFavourite = UIImage(systemName: "heart.fill")!
    static let notFavourite = UIImage(systemName: "heart")!
    static let placeholder = UIImage(systemName: "film")!.withTintColor(.secondaryLabel, renderingMode: .alwaysTemplate)
}
