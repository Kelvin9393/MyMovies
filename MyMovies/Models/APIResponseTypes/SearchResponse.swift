//
//  SearchResponse.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Foundation

struct SearchResponse: Decodable {
    let resultCount: Int?
    let results: [Movie]?
}
