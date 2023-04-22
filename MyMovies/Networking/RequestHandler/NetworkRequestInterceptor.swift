//
//  NetworkRequestInterceptor.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

class NetworkRequestInterceptor: RequestInterceptor {
    
    let retryLimit = 5
    let retryDelay: TimeInterval = 10
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        
        if let statusCode = response?.statusCode,
           (500...599).contains(statusCode),
           request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else {
            completion(.doNotRetry)
        }
    }
}
