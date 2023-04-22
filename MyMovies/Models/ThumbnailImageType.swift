//
//  ThumbnailImageType.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 22/04/2023.
//

import Foundation

enum ThumbnailImageType {
    case imageUrl(URL)
    case imageData(Data)
    case imageFilePath(String)
    case none
}
