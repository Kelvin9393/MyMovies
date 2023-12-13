//
//  VisitedHistoryService.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 23/10/2023.
//

import Foundation
import CoreData

protocol VisitedHistoryServiceProtocol: AnyObject {
    init(coreDataManager: CoreDataManager)
    func getVistedHistories() -> [VisitHistory]?
    @discardableResult func updateVisitedHistory(forTrackId trackId: Int32, visitHistory: VisitHistory?) -> VisitHistory
}

class VisitedHistoryService: VisitedHistoryServiceProtocol {
    let context: NSManagedObjectContext
    let coreDataManager: CoreDataManager

    required init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.context = coreDataManager.managedContext
        self.coreDataManager = coreDataManager
    }

    func getVistedHistories() -> [VisitHistory]? {
        do {
            let visitHistories = try context.fetch(VisitHistory.fetchRequest())
            return visitHistories
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func updateVisitedHistory(forTrackId trackId: Int32, visitHistory: VisitHistory?) -> VisitHistory {
        if let visitHistory = visitHistory {
            self.updateVisitedHistory(forVisitHistory: visitHistory)
            return visitHistory
        } else {
            let visitHistory = self.addNewVisitedHistory(for: trackId)
            return visitHistory
        }
    }

    private func addNewVisitedHistory(for trackId: Int32) -> VisitHistory {
        let newVisitHistory = VisitHistory(context: context)
        newVisitHistory.trackId = Int32(trackId)
        newVisitHistory.visitedDate = Date()

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }

        return newVisitHistory
    }

    private func updateVisitedHistory(forVisitHistory visitHistory: VisitHistory) {
        visitHistory.visitedDate = Date()

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
