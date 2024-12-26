//
//  NumberLaunches.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.01.2022.
//

import Foundation

protocol NumberLaunchesProtocol {
    @discardableResult
    func launch() -> Self
    func isFirstLaunch() -> Bool
}

final class NumberLaunches: NumberLaunchesProtocol {
    struct Constants {
        static let countLaunchKey = "otter.scale.ios_launches_key"
    }
    
    @discardableResult
    func launch() -> Self {
        var count = UserDefaults.standard.integer(forKey: Constants.countLaunchKey)
        
        if count <= (Int.max - 1) {
            count += 1
        }
        
        UserDefaults.standard.set(count, forKey: Constants.countLaunchKey)
        
        return self
    }
    
    func isFirstLaunch() -> Bool {
        UserDefaults.standard.integer(forKey: Constants.countLaunchKey) == 1
    }
}
