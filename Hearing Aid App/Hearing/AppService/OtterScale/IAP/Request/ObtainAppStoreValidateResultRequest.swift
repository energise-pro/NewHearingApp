//
//  ObtainPaymentDataRequest.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 16.01.2022.
//

struct ObtainAppStoreValidateResultRequest: EndPoint {
    let apiKey: String
    let externalUserID: String?
    let internalUserID: String?
    
    var path: String {
        "/api/v1/sdk/payment_data"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        var params = [
            "_api_key": apiKey
        ]
        
        if let externalUserID = externalUserID {
            params["external_user_id"] = externalUserID
        }
        
        if let internalUserID = internalUserID {
            params["internal_user_id"] = internalUserID
        }
        
        return params
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json",
        ]
    }
}
