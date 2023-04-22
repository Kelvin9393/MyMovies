//
//  SearchRouter.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

enum SearchRouter {
    case getAllMovies
    case search(term: String)
}

extension SearchRouter: URLRequestBuilder {
    var path: String {
        switch self {
        case .getAllMovies:
            return "/search"
        case .search:
            return "/search"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAllMovies:
            return [
                "term": "star",
                "country": "au",
                "media": "movie"
            ]
        case let .search(term):
            return [
                "term": term,
                "country": "au",
                "media": "movie"
            ]
        }
    }
    
}
