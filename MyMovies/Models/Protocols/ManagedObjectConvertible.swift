//
//  ManagedObjectConvertible.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 22/04/2023.
//

import Foundation
import CoreData

/// Protocol to provide functionality for Core Data managed object conversion.
protocol ManagedObjectConvertible {
    associatedtype ManagedObject

    /// Converts a conforming instance to a managed object instance.
    ///
    /// - Parameter context: The managed object context to use.
    /// - Returns: The converted managed object instance.
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject?
}
