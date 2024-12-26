//
//  URLRequest+EndPoint.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 11.01.2022.
//

import Foundation

extension URLRequest {
    init?(domain: String, endPoint: EndPoint) {
        guard let url = Self.url(domain: domain, endPoint: endPoint) else {
            return nil
        }
        
        self = URLRequest(url: url)
        
        httpMethod = endPoint.method.rawValue
        allHTTPHeaderFields = endPoint.headers
        httpBody = Self.jsonBody(endPoint: endPoint)
    }
}

// MARK: Private
private extension URLRequest {
    static func url(domain: String, endPoint: EndPoint) -> URL? {
        guard var components = URLComponents(string: domain) else {
            return nil
        }
        
        components.path = components.path + endPoint.path
        components.queryItems = queryItems(endPoint: endPoint)
        
        return components.url
    }
    
    static func queryItems(endPoint: EndPoint) -> [URLQueryItem]? {
        let parameters = endPoint.parameters
        
        guard endPoint.method == .get, !parameters.isEmpty else {
            return nil
        }
        
        return parameters.map { key, value -> URLQueryItem in
            URLQueryItem(name: key,
                         value: String(describing: value))
        }
    }
    
    static func jsonBody(endPoint: EndPoint) -> Data? {
        let parameters = endPoint.parameters
        
        guard [.post, .put, .patch, .delete].contains(endPoint.method), !parameters.isEmpty  else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
