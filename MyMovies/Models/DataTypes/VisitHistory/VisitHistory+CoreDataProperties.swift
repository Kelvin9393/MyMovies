//
//  VisitHistory+CoreDataProperties.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 11/01/2023.
//
//

import Foundation
import CoreData


extension VisitHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisitHistory> {
        return NSFetchRequest<VisitHistory>(entityName: "VisitHistory")
    }

    @NSManaged public var trackId: Int32
    @NSManaged public var visitedDate: Date?

}

extension VisitHistory : Identifiable {

}
