//
//  FavouriteMovie+CoreDataProperties.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/12/2023.
//
//

import Foundation
import CoreData


extension FavouriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteMovie> {
        return NSFetchRequest<FavouriteMovie>(entityName: FavouriteMovie.entityName)
    }

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl30: String?
    @NSManaged public var collectionName: String?
    @NSManaged public var collectionPrice: NSDecimalNumber?
    @NSManaged public var currency: String?
    @NSManaged public var favouriteDate: Date?
    @NSManaged public var imageUrl: String?
    @NSManaged public var longDescription: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var primaryGenreName: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var thumbnailImageData: Data?
    @NSManaged public var trackId: Int32
    @NSManaged public var trackName: String?
    @NSManaged public var trackPrice: NSDecimalNumber?
    @NSManaged public var trackViewUrl: String?
    @NSManaged public var visitHistory: VisitHistory?

}

extension FavouriteMovie : Identifiable {

}
