//
//  InfoHelper.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 17.01.2022.
//

import Foundation
import UIKit

protocol InfoHelperProtocol {
    var locale: String? { get }
    var currencyCode: String? { get }
    var countryCode: String? { get }
    var idfv: String? { get }
}

final class InfoHelper: InfoHelperProtocol {
    var locale: String? {
        guard let mainPreferredLanguage = Locale.preferredLanguages.first else {
            return nil
        }
        
        return Locale(identifier: mainPreferredLanguage).languageCode
    }
    
    var currencyCode: String? {
        Locale.current.currencyCode
    }
    
    var countryCode: String? {
        (Locale.current as NSLocale).countryCode
    }
    
    var idfv: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }
}
