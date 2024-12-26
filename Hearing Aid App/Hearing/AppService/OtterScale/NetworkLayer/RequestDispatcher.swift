//
//  RequestDispatcher.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 11.01.2022.
//

import Foundation

protocol RequestDispatcherProtocol {
    init(environment: APIEnvironmentProtocol, networkSession: NetworkSessionProtocol)
    
    func execute(endPoint: EndPoint, completion: @escaping (Any?) -> Void) -> URLSessionDataTask?
}

final class RequestDispatcher: RequestDispatcherProtocol {
    private let environment: APIEnvironmentProtocol
    private let networkSession: NetworkSessionProtocol
    
    init(environment: APIEnvironmentProtocol, networkSession: NetworkSessionProtocol) {
        self.environment = environment
        self.networkSession = networkSession
    }
}

// MARK: Internal
extension RequestDispatcher {
    func execute(endPoint: EndPoint, completion: @escaping (Any?) -> Void) -> URLSessionDataTask? {
        guard let request = URLRequest(domain: environment.host, endPoint: endPoint) else {
            completion(nil)
            return nil
        }
        
        let task = networkSession.dataTask(request: request) { [weak self] data, response, error in
            let result = self?.parse(data: data)
            completion(result)
        }
        
        task?.resume()
        
        return task
    }
}

// MARK: Private
private extension RequestDispatcher {
    func parse(data: Data?) -> Any? {
        guard let data = data else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
