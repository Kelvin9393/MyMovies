//
//  ModelConvertible.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 22/04/2023.
//

import Foundation

/// Protocol to provide functionality for data model conversion.
protocol ModelConvertible {
    associatedtype Model

    /// Converts a conforming instance to a data model instance.
    ///
    /// - Returns: The converted data model instance.
    func toModel() -> Model?
}
