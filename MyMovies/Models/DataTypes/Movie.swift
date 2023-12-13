//
//  Movie.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Foundation
import CoreData

struct Movie: Decodable {

    let artistName: String?
    let artworkUrl30: String?
    let collectionName: String?
    let collectionPrice: Double?
    let currency: String?
    let longDescription: String?
    let previewUrl: String?
    let primaryGenreName: String?
    let releaseDate: String?
    let trackId: Int
    let trackName: String?
    let trackPrice: Double?
    let trackViewUrl: String?
}

// MARK: - MovieDisplayable
extension Movie: MovieDisplayable {
    var name: String? {
        trackName ?? collectionName
    }
    
    var price: Double? {
        trackPrice ?? collectionPrice
    }
    
    var strReleaseDate: String? {
        Date.convertToDate(from: releaseDate ?? "")?.convertToString()
    }
    
    var convertedReleaseDate: Date? {
        Date.convertToDate(from: releaseDate ?? "")
    }
    
    var genre: String? {
        primaryGenreName
    }
    
    var thumbnailImage: ThumbnailImageType {
        guard let url = imageUrl(with: .s340) else {
            return .none
        }

        return .imageUrl(url)
    }
    
    enum ImageSize: Int {
        case s340 = 340
        case s600 = 600
    }
    
    func imageUrl(with size: ImageSize) -> URL? {
        guard let urlString = artworkUrl30 as? NSString else {
            return nil
        }
        
        let fileName = urlString.lastPathComponent
        let fileNameParts = fileName.components(separatedBy: ".")
        let newUrlString = "\(urlString.deletingLastPathComponent)/\(size.rawValue)x\(size.rawValue)bb.\(fileNameParts[1])"
        
        return URL(string: newUrlString)
    }
}


// MARK: - ManagedObjectConvertible
extension Movie: ManagedObjectConvertible {
    func toManagedObject(in context: NSManagedObjectContext) -> FavouriteMovie? {
        let entityName = FavouriteMovie.entityName
        let favouriteMovie = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! FavouriteMovie
        favouriteMovie.trackId = Int32(trackId)
        favouriteMovie.artistName = artistName
        favouriteMovie.trackName = trackName
        favouriteMovie.collectionName = collectionName
        favouriteMovie.imageUrl = imageUrl(with: .s600)?.absoluteString

        if let trackPrice = trackPrice {
            favouriteMovie.trackPrice = NSDecimalNumber(string: "\(trackPrice)")
        }

        if let collectionPrice = collectionPrice {
            favouriteMovie.collectionPrice = NSDecimalNumber(string: "\(collectionPrice)")
        }

        favouriteMovie.releaseDate = convertedReleaseDate
        favouriteMovie.currency = currency
        favouriteMovie.previewUrl = previewUrl
        favouriteMovie.primaryGenreName = primaryGenreName
        favouriteMovie.longDescription = longDescription
        favouriteMovie.favouriteDate = Date()
        favouriteMovie.trackViewUrl = trackViewUrl
        favouriteMovie.artworkUrl30 = artworkUrl30

        return favouriteMovie
    }
}
