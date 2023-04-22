//
//  SharedData.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 12/01/2023.
//

import UIKit
import CoreData

final class SharedData {

    // MARK: - CoreData
    var context: NSManagedObjectContext? {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return context
    }
    
    private static var shared: SharedData!
    
    private let userDefaults: UserDefaults
    private let dispatchGroup = DispatchGroup()
    
    let applicationDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    private(set) lazy var favouriteMovies = [FavouriteMovie]() {
        didSet {
            favouriteMovieDict = favouriteMovies.reduce(into: [:]) { $0[$1.trackId] = $0.count }
        }
    }
    private(set) lazy var visitHistories = [VisitHistory]() {
        didSet {
            visitHistoryDict = visitHistories.reduce(into: [:]) { $0[$1.trackId] = $1.visitedDate }
        }
    }
    
    var favouriteMovieDict: [Int32: Int] = [:]
    var visitHistoryDict: [Int32: Date] = [:]
    
    private enum UserDefaultsKey {
        static let lastSelectedTab = "lastSelectedTab"
    }

    static func shared(userDefaults: UserDefaults = .standard) -> SharedData {
        if shared == nil {
            shared = SharedData(userDefaults: userDefaults)
        }

        return shared
    }

    private init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - UserDefaults
    var lastSelectedTab: Int {
        get {
            return SharedData.shared().userDefaults.integer(forKey: UserDefaultsKey.lastSelectedTab)
        }
        
        set {
            SharedData.shared().userDefaults.set(newValue, forKey: UserDefaultsKey.lastSelectedTab)
        }
    }
    
    // MARK: - CoreData
    public func addNewFavouriteMovie(movie: Movie,
                                     movieImage: UIImage?,
                                     completion: ((FavouriteMovie) -> ())? = nil) {
        guard let context = context,
              let newFavouriteMovie = movie.toManagedObject(in: context) else { return }

        do {
            try context.save()

            do {
                if let fileName = newFavouriteMovie.fileName {
                    try movieImage?.pngData()?.write(to: applicationDocumentsDirectory.appendingPathComponent(fileName), options: .atomic)
                }
            } catch {
                print("Error writing file: \(error)")
            }

            getFavouriteMovies()
            completion?(newFavouriteMovie)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteFavouriteMovie(movie: FavouriteMovie,
                                     completion: (() -> ())? = nil) {
        guard let context = context else { return }
        
        let fileName = movie.fileName
        
        context.delete(movie)
        
        do {
            try context.save()
            
            if let fileName = fileName {
                do {
                    print(applicationDocumentsDirectory.appendingPathComponent(fileName).path())
                    try FileManager.default.removeItem(at: applicationDocumentsDirectory.appendingPathComponent(fileName))
                } catch {
                    print("Error removing file \(error)")
                }
            }
            
            favouriteMovies.removeAll(where: { $0 === movie })
            completion?()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func addNewVisitedHistory(for trackId: Int) {
        guard let context = context else { return }
        
        let newVisitHistory = VisitHistory(context: context)
        newVisitHistory.trackId = Int32(trackId)
        newVisitHistory.visitedDate = Date()
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    public func updateVisitedHistory(forTrackId trackId: Int) {
        if let visitHistory = SharedData.shared().visitHistories.first(where: { $0.trackId == trackId }) {
            SharedData.shared().updateVisitedHistory(forVisitHistory: visitHistory)
        } else {
            SharedData.shared().addNewVisitedHistory(for: trackId)
        }
    }
    
    public func updateVisitedHistory(forVisitHistory visitHistory: VisitHistory) {
        guard let context = context else { return }
        
        visitHistory.visitedDate = Date()
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getFavouriteMovies() {
        guard let context = context else { return }

        dispatchGroup.enter()
        
        do {
            let request = FavouriteMovie.fetchRequest()
            let sort = NSSortDescriptor(key: "favouriteDate", ascending: false)
            request.sortDescriptors = [sort]
            
            favouriteMovies = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        dispatchGroup.leave()
    }
    
    public func getVistedHistories() {
        guard let context = context else { return }

        dispatchGroup.enter()
        
        do {
            visitHistories = try context.fetch(VisitHistory.fetchRequest())
        } catch {
            print(error.localizedDescription)
        }
        
        dispatchGroup.leave()
    }
    
    public func getFavouriteMoviesAndVisitedHistories(completion: (() -> ())? = nil) {
        getFavouriteMovies()
        getVistedHistories()
        
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
}
