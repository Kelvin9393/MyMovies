//
//  APIError.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

enum APIError: Error {
    
    static let generalErrorTitle = "Something went wrong"
    static let generalErrorDescription = "Please check your connection and try again."
    
    var generalError: String {
        "Please check your connection and try again."
    }
    
    case noInternetConnectivity
    case notFound
    case internalServerError
    case unknownError
    case afError(AFError)
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnectivity, .unknownError:
            return APIError.generalErrorDescription
        case .notFound:
            return "Sorry, we can't find the page you're looking for."
        case .internalServerError:
            return "We're having a problem with our system. Please try again later."
        case .afError(let error):
            return error.localizedDescription
        }
    }
}
