//
//  APIRequest.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

/// API protocol, The alamofire wrapper
protocol APIRequest: APIResponse { }

private let configuration: URLSessionConfiguration = {
    let timeout = 20
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForResource = TimeInterval(timeout)
    configuration.timeoutIntervalForRequest = TimeInterval(timeout)
    configuration.httpShouldUsePipelining = true
    configuration.waitsForConnectivity = true
    return configuration
}()

private let sessionManager: Session = {
    let networkLogger = NetworkLogger()
    let interceptor = NetworkRequestInterceptor()
    return Session(configuration: configuration, interceptor: interceptor, eventMonitors: [networkLogger])
}()

extension APIRequest where Self: URLRequestBuilder {
    @discardableResult
    func send<T: Decodable>(_ decoder: T.Type, completion: CallResponse<T>) -> Request {
        return sessionManager.request(self)
            .responseData { (response) in
                self.handleResponse(response, completion: completion)
            }
    }
}
