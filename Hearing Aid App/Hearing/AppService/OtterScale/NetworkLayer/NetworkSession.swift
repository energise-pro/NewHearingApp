//
//  NetworkSession.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 11.01.2022.
//

import Foundation

protocol NetworkSessionProtocol {
    func dataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask?
}

final class NetworkSession: NetworkSessionProtocol {
    deinit {
        session?.invalidateAndCancel()
        session = nil
    }
    
    private var session: URLSession?
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = false
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        
        session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }
}

// MARK: Internal
extension NetworkSession {
    func dataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        session?.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
    }
}
