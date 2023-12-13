//
//  FavouriteMovie+CoreDataClass.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 11/01/2023.
//
//

import Foundation
import CoreData

public class FavouriteMovie: NSManagedObject {
    static let entityName = "FavouriteMovie"
}

extension FavouriteMovie: MovieDisplayable {
    var name: String? {
        trackName ?? collectionName
    }
    
    var thumbnailImage: ThumbnailImageType {
        guard let thumbnailImageData = thumbnailImageData else {
            return .none
        }

        return .imageData(thumbnailImageData)
    }
    
    var strReleaseDate: String? {
        releaseDate?.convertToString()
    }
    
    var genre: String? {
        primaryGenreName
    }
    
    var price: Double? {
        (trackPrice ?? collectionPrice)?.doubleValue
    }
}

// MARK: - ModelConvertible
extension FavouriteMovie: ModelConvertible {
    func toModel() -> Movie? {
        Movie(
            artistName: artistName,
            artworkUrl30: artworkUrl30,
            collectionName: collectionName,
            collectionPrice: collectionPrice?.doubleValue,
            currency: currency,
            longDescription: longDescription,
            previewUrl: previewUrl,
            primaryGenreName: primaryGenreName,
            releaseDate: releaseDate?.convertToString(dateFormat: Date.serverDateFormat),
            trackId: Int(trackId),
            trackName: trackName,
            trackPrice: trackPrice?.doubleValue,
            trackViewUrl: trackViewUrl)
    }
}
