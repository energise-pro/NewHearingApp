//
//  AppStoreReceipt.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 15.01.2022.
//

import Foundation

protocol AppStoreReceiptSourceProtocol {
    func appStoreReceiptData() -> Data?
    func appStoreReceipt(parser: AppStoreReceiptParserProtocol) -> AppStoreReceipt?
}

final class AppStoreReceiptSource: AppStoreReceiptSourceProtocol {
    func appStoreReceiptData() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }

        return try? Data(contentsOf: url)
    }
    
    func appStoreReceipt(parser: AppStoreReceiptParserProtocol = AppStoreReceiptParser()) -> AppStoreReceipt? {
        guard let data = appStoreReceiptData() else {
            return nil
        }
        
        return try? parser.parse(from: data)
    }
}
