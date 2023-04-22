//
//  NetworkLogger.swift
//  MyMovies
//
//  Created by KELVIN LING SHENG SIANG on 07/01/2023.
//

import Alamofire

class NetworkLogger: EventMonitor {
    
    let queue = DispatchQueue(label: "com.kluangmall.user")
    
    func requestDidFinish(_ request: Request) {
        print(request.description)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        guard let data = response.data else { return }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            print(json)
        }
    }
}

