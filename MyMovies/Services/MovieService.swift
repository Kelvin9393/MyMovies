//
//  MovieService.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 21/10/2023.
//

import Foundation
import Alamofire

protocol MovieServiceProtocol {
    @discardableResult func getAllMovies(completion: @escaping (Result<SearchResponse, APIError>) -> Void) -> Request
    @discardableResult func searchMovie(for term: String, completion: @escaping (Result<SearchResponse, APIError>) -> Void) -> Request
}

class MovieService: MovieServiceProtocol {
    func getAllMovies(completion: @escaping (Result<SearchResponse, APIError>) -> Void) -> Request {
        return SearchRouter.getAllMovies.send(SearchResponse.self, completion: completion)
    }

    func searchMovie(for term: String, completion: @escaping (Result<SearchResponse, APIError>) -> Void) -> Request {
        return SearchRouter.search(term: term).send(SearchResponse.self, completion: completion)
    }
}

