//
//  FavouriteMovieService.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 22/10/2023.
//

import Foundation
import CoreData

protocol FavouriteMovieServiceProtocol {
    init(coreDataManager: CoreDataManager)
    func getFavouriteMovies() -> [FavouriteMovie]?
    @discardableResult func addNewFavouriteMovie(movie: Movie,
                                                 movieImageData: Data?,
                                                 visitHistory: VisitHistory?) -> FavouriteMovie?
    func deleteFavouriteMovie(movie: FavouriteMovie)
}

class FavouriteMovieService: FavouriteMovieServiceProtocol {
    let context: NSManagedObjectContext
    let coreDataManager: CoreDataManager

    required init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.context = coreDataManager.managedContext
        self.coreDataManager = coreDataManager
    }

    func getFavouriteMovies() -> [FavouriteMovie]? {
        do {
            let request = FavouriteMovie.fetchRequest()
            let sort = NSSortDescriptor(key: "favouriteDate", ascending: false)
            request.sortDescriptors = [sort]

            let favouriteMovies = try context.fetch(request)
            return favouriteMovies
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }
    
    func addNewFavouriteMovie(movie: Movie, movieImageData: Data?, visitHistory: VisitHistory?) -> FavouriteMovie? {
        guard let newFavouriteMovie = movie.toManagedObject(in: context) else {
            return nil
        }

        newFavouriteMovie.thumbnailImageData = movieImageData
        newFavouriteMovie.visitHistory = visitHistory

        do {
            try context.save()
            return newFavouriteMovie
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func deleteFavouriteMovie(movie: FavouriteMovie) {

        context.delete(movie)

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
