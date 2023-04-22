//
//  Date+Extension.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Foundation

extension Date {

    static let serverDateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
    
    /// Return Date object from string
    /// - Parameters:
    ///   - stringDate: String to be parse
    ///   - dateFormat: Format of date in string, default by yyyy-MM-dd'T'HH:mm:SSZ
    /// - Returns: A date representation of string. If convertToDate can’t parse the string, returns nil.
    static func convertToDate(from stringDate: String, withFormat dateFormat: String = serverDateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: stringDate)
    }
    
    
    /// Return String from Date object
    /// - Parameter dateFormat: Format of date to be expected, default by d MMM yyyy
    /// - Returns: Stringify date from Date object
    func convertToString(dateFormat: String = "d MMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
