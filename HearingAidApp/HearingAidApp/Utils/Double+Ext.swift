//
//  Double+Ext.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 19.12.2022.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
