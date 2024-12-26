//
//  AppStoreReceiptFetcher.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 15.01.2022.
//

import Foundation

protocol AppStoreReceiptFetcherProtocol {
    init(appStoreReceipt: AppStoreReceiptSourceProtocol)
    
    func fetch(completion: @escaping (String?) -> Void)
}

final class AppStoreReceiptFetcher: AppStoreReceiptFetcherProtocol {
    deinit {
        refreshRequest?.cancel()
        refreshRequest = nil
    }
    
    private var refreshRequest: AppStoreReceiptRefreshRequest?
    
    private let appStoreReceipt: AppStoreReceiptSourceProtocol
    
    init(appStoreReceipt: AppStoreReceiptSourceProtocol = AppStoreReceiptSource()) {
        self.appStoreReceipt = appStoreReceipt
    }
}

// MARK: Internal
extension AppStoreReceiptFetcher {
    func fetch(completion: @escaping (String?) -> Void) {
        if let receiptData = appStoreReceipt.appStoreReceiptData() {
            let encoded = self.encode(data: receiptData)
            completion(encoded)
        } else {
            refreshRequest = AppStoreReceiptRefreshRequest { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success:
                    if let receiptData = self.appStoreReceipt.appStoreReceiptData() {
                        let encoded = self.encode(data: receiptData)
                        completion(encoded)
                    }
                case .error:
                    completion(nil)
                }
                
                self.refreshRequest = nil
            }
            
            refreshRequest?.refresh()
        }
    }
}

// MARK: Private
extension AppStoreReceiptFetcher {
    func encode(data: Data) -> String {
        data.base64EncodedString()
    }
}
