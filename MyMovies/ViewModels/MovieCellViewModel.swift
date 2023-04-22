//
//  MovieCellViewModel.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 12/01/2023.
//

import UIKit

struct MovieCellViewModel {
    let title: String?
    let thumbnail: ThumbnailImageType
    let genre: String?
    let price: String?
    let lastVisited: String?
    let isFavourite: Bool
    
    var favouriteImage: UIImage {
        isFavourite ? .isFavourite : .notFavourite
    }
    
    init(with movie: MovieDisplayable, isFavourite: Bool, lastVisitedDate: Date?) {
        title = movie.name
        thumbnail = movie.thumbnailImage
        genre = movie.genre
        self.isFavourite = isFavourite
        
        if let price = movie.price {
            self.price = "\(movie.currency ?? "$")\(String(format: "%.2f", price))"
        } else {
            self.price = nil
        }
        
        if let lastVisitedDate = lastVisitedDate {
            lastVisited = "Last visit on \(lastVisitedDate.convertToString(dateFormat: "d MMM yyyy"))"
        } else {
            lastVisited = nil
        }
    }
}
