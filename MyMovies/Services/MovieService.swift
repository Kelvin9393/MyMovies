//
//  MovieService.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 21/10/2023.
//

import Foundation

protocol MovieServiceProtocol: AnyObject {
    func getAllMovies(completion: @escaping (Result<SearchResponse, APIError>) -> Void)
    func searchMovie(for term: String, completion: @escaping (Result<SearchResponse, APIError>) -> Void)
}

class MovieService: MovieServiceProtocol {
    func getAllMovies(completion: @escaping (Result<SearchResponse, APIError>) -> Void) {
        SearchRouter.getAllMovies.send(SearchResponse.self, completion: completion)
    }

    func searchMovie(for term: String, completion: @escaping (Result<SearchResponse, APIError>) -> Void) {
        SearchRouter.search(term: term).send(SearchResponse.self, completion: completion)
    }
}

