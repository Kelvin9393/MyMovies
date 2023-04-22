//
//  APIResponse.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

/// Response completion handler beautified
typealias CallResponse<T> = ((Result<T, APIError>) -> ())?

protocol APIResponse {
    /// Handles request response, never called anywhere but APIRequestHandler
    ///
    /// - Parameters:
    ///   - response: response from network request, for now alamofire Data response
    ///   - completion: completing processing the json response, and delivering it in the completion handler
    func handleResponse<T: Decodable>(_ response: AFDataResponse<Data>, completion: CallResponse<T>)
}

extension APIResponse {
    
    func handleResponse<T: Decodable>(_ dataResponse: AFDataResponse<Data>, completion: CallResponse<T>) {
        
        if let statusCode = dataResponse.response?.statusCode {
            print("debugPrint: Response code: \(statusCode)")
        } else {
            print("debugPrint: No response code")
        }
        
        switch dataResponse.result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                
                completion?(.success(result))
            } catch {
                completion?(.failure(.unknownError))
            }
            
        case .failure(let error):
            print(error.localizedDescription)
            if error.isExplicitlyCancelledError {
                completion?(.failure(.afError(error)))
                return
            }
            
            guard let isReachable = NetworkReachabilityManager()?.isReachable, isReachable else {
                completion?(.failure(.noInternetConnectivity))
                return
            }
            
            if error.responseCode == 404 {
                completion?(.failure(.notFound))
            } else if error.responseCode == 500 {
                completion?(.failure(.internalServerError))
            } else {
                completion?(.failure(.unknownError))
            }
        }
    }
    
}

