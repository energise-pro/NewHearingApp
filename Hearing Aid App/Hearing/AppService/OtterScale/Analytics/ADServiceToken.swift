//
//  ADServiceToken.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.01.2022.
//

import AdServices

protocol ADServiceTokenProtocol {
    func attributionToken() -> String?
}

final class ADServiceToken: ADServiceTokenProtocol {
    func attributionToken() -> String? {
        if #available(iOS 14.3, *) {
            return try? AAAttribution.attributionToken()
        }

        return nil
    }
}
