//
//  UserSetResponse.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 16.01.2022.
//

protocol UserSetResponseProtocol {
    func map(response: Any) -> Bool
}

final class UserSetResponse: UserSetResponseProtocol {
    func map(response: Any) -> Bool {
        guard
            let json = response as? [String: Any],
            let code = json["_code"] as? Int
        else {
            return false
        }
        
        return code == 200
    }
}
