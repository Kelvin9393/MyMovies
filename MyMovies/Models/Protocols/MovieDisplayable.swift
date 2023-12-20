//
//  MovieDisplayable.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 22/04/2023.
//

import Foundation

protocol MovieDisplayable {
    var name: String? { get }
    var thumbnailImage: ThumbnailImageType { get }
    var genre: String? { get }
    var currency: String? { get }
    var price: Double? { get }
    var strReleaseDate: String? { get }
    var artistName: String? { get }
    var longDescription: String? { get }
    var previewUrl: String? { get }
}
