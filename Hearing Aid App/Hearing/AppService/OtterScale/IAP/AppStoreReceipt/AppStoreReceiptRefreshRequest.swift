//
//  AppStoreReceiptRefreshRequest.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 15.01.2022.
//

import StoreKit

enum AppStoreReceiptRefreshRequestResult {
    case success
    case error(Error)
}

final class AppStoreReceiptRefreshRequest: NSObject {
    deinit {
        request.cancel()
        request.delegate = nil
    }
    
    private let request = SKReceiptRefreshRequest()
    
    private let completion: (AppStoreReceiptRefreshRequestResult) -> Void
    
    init(completion: @escaping (AppStoreReceiptRefreshRequestResult) -> Void) {
        self.completion = completion
        
        super.init()
        
        request.delegate = self
    }
}

// MARK: Internal
extension AppStoreReceiptRefreshRequest {
    func refresh() {
        request.start()
    }
    
    func cancel() {
        request.cancel()
    }
}

// MARK: SKRequestDelegate
extension AppStoreReceiptRefreshRequest: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        performCallback(result: .success)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        performCallback(result: .error(error))
    }
}

// MARK: Private
private extension AppStoreReceiptRefreshRequest {
    func performCallback(result: AppStoreReceiptRefreshRequestResult) {
        DispatchQueue.main.async { [weak self] in
            self?.completion(result)
        }
    }
}
