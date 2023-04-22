//
//  URLRequestBuilder.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

protocol URLRequestBuilder: URLRequestConvertible, APIRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
}

extension URLRequestBuilder {
    
    var baseUrl: URL {
        guard let url = URL(string: APIConstants.baseUrl) else { fatalError("baseUrl could not be configured.")}
        return url
    }

    var requestUrl: URL {
        return baseUrl.appendingPathComponent(path)
    }

    var headers: HTTPHeaders? {
        return [:]
    }

    var parameters: Parameters? {
        return [:]
    }

    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var urlRequest: URLRequest {
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        print("debugPrint: \(request.allHTTPHeaderFields as Any)")
        
        return request
    }

    func asURLRequest() throws -> URLRequest {
        let request = try encoding.encode(urlRequest, with: parameters)
        print("debugPrint: \(request.url?.absoluteString as Any)")
        print("debugPrint: \(String(describing: parameters))")
        return request
    }

}
