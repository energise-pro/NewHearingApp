//
//  Constants.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

import Foundation

enum Constants {
    
    enum App {
        
        static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        static let bundleId = Bundle.main.bundleIdentifier!
        static let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    enum Support {
        
        // Common
        static let email = "lidia.michalak@polandmail.com"
        
        // Support
        static let supportTitle = String(format: "%@ – Support".localized, App.name)
        static let supportBody = String(format: "<p>My app identificator: %@<br>App Version: %@(%@)</p><br>".localized,
                                        PurchasesService.userId, App.versionNumber, App.buildNumber)
        
        // Cancel Subscription
        static let cancelSubscriptionTitle = String(format: "%@ – Cancel subscription".localized, App.name)
        static let cancelSubscriptionBody = String(format: "<p>My app identificator: %@<br>App Version: %@(%@)</p><br>".localized,
                                                   PurchasesService.userId, App.versionNumber, App.buildNumber)
    }
    
    enum Link {
        
        static let privacyPolicy = URL(string: "https://hearingsapp.info/privacy-policy")!
        static let termsOfUse = URL(string: "https://hearingsapp.info/terms")!
    }
}
