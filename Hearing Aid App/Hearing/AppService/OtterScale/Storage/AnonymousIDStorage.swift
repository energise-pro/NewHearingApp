//
//  AnonymousID.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.01.2022.
//

import Foundation

protocol AnonymousIDStorageProtocol {
    func getAnonymousID() -> String
}

final class AnonymousIDStorage: AnonymousIDStorageProtocol {
    func getAnonymousID() -> String {
        let udKey = "otter.scale.ios_anonymous_id"
        
        if let randomKey = UserDefaults.standard.string(forKey: udKey) {
            return randomKey
        } else {
            let letters = "abcdefghijklmnopqrstuvwxyz"
            let randomKey = String((0..<64).map{ _ in letters.randomElement()! })
            let result = String(format: "anon_id_%@", randomKey)
            UserDefaults.standard.set(result, forKey: udKey)
            return result
        }
    }
}
