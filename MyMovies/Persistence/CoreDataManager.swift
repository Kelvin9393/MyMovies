//
//  CoreDataManager.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 20/10/2023.
//

import Foundation
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    ///Prevent clients from creating another instance. https://medium.com/@maddy.lucky4u/swift-4-core-data-part-3-creating-a-singleton-core-data-refactoring-insert-update-delete-9811af2fcf75
    private init() {}

    func saveContext() {
        saveContext(mainContext)
    }

    func saveContext(_ context: NSManagedObjectContext) {
        if context.parent == mainContext {
            saveDerivedContext(context)
            return
        }

        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.perform { [self] in
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            saveContext(mainContext)
        }
    }
}
