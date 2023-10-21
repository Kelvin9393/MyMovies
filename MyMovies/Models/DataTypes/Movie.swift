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
        guard let entitiyDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            NSLog("Can't create entity \(entityName)")
            return nil
        }

        let object = FavouriteMovie(entity: entitiyDescription, insertInto: context)
        object.trackId = Int32(trackId)
        object.artistName = artistName
        object.trackName = trackName
        object.collectionName = collectionName
        object.imageUrl = imageUrl(with: .s600)?.absoluteString

        if let trackPrice = trackPrice {
            object.trackPrice = NSDecimalNumber(string: "\(trackPrice)")
        }

        if let collectionPrice = collectionPrice {
            object.collectionPrice = NSDecimalNumber(string: "\(collectionPrice)")
        }

        object.releaseDate = convertedReleaseDate
        object.currency = currency
        object.previewUrl = previewUrl
        object.primaryGenreName = primaryGenreName
        object.longDescription = longDescription
        object.thumbnailImageId = UUID().uuidString
        object.favouriteDate = Date()
        object.trackViewUrl = trackViewUrl
        object.artworkUrl30 = artworkUrl30

        return object
    }
}
