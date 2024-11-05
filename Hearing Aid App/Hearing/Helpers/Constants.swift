import UIKit

struct CAppConstants {
    
    struct General {
        static let APIKey = "t81CDA5dxW4n12OBI"
        static let baseURL = "https://ahearing.energise.pro/api/"
        static let appStoreAppID = "1566596774"
        static let amplitudeKey = "43ec1a759310e6328f53ce03e27ca732"
        static let oneSignalKey = "f77b7c6b-b5f7-4741-a347-d969586af566"
        static let supportEmail = "artemsherbachuk@icloud.com"
        static let appHudKey = "app_LKNcgDKSHwrHpuppKR8ajagnmV7ur1"
        static let asaToolsKey = "958eebf0-3281-4388-85dd-4875d90cdf34"
        
        static let countForPresentingRatingAlert = 2
    }
    
    struct Keys {
        static let isMigratedReceipts = "isMigratedReceipts"
        static let wasUsedTrial = "kUsedTrial"
        static let launchCount = "AppLaunchCount"
        static let needsSkipSearchAdsTracking = "needsSkipSearchAdsTracking"
        static let wasPresentedCatchUp = "kPresentedCatchUp"
        static let wasConfiguredPushOffer = "kConfiguredPushOffer"
        static let wasPresentedRatingAlert = "kPresentedRatingAlert"
        static let wasSentASAInstall = "wasSentASAInstall"
        
        /// These keys related with https://appstoreconnect.apple.com and can't be changed only in the one place.
        static let weeklySubscriptionId = "hearing_aid_weekly"
        static let monthlySubscriptionId = "hearing_aid_monthly_new"
        static let annualSubscriptionId = "hearing_aid_annual"
        static let lifetimePurchase = "hearing_aid_lifetime"
        static let yearlyNoTrialSubscriptionId = "hearing_aid_annual_no_trial"
        static let yearlyNoTrial2SubscriptionId = "hearing_aid_annual_no_trial_29.99"
        
        /// One Signal Screen names
        static let catchUpScreenName = "catch_up"
        static let paywallScreenName = "paywall"
    }
    
    struct Colors {
        static let lightRed: UIColor = UIColor(hex: "#FF6D6D")!
    }
    
    struct Images {
        static let icVolumeDownUnactive = UIImage(named: "icValueDownUnactive")!
        static let icVolumeDownActive = UIImage(named: "icVolumeDownActive")!
        static let icVolumeUpActive = UIImage(named: "icVolumeUpActive")!
        static let icVolumeUpUnactive = UIImage(named: "icVolumeUpUnactive")!
        static let icAppIcon = UIImage(named: "settingsAppIcon")!
        
        static let icProSetup = UIImage(named: "icProSetup")!
        static let icNoiseOff = UIImage(named: "icNoiseOff")!
        static let icStereo = UIImage(named: "icStereo")!
        static let icTemplates = UIImage(named: "icTemplates")!
        static let icInstructionInfo = UIImage(named: "icInstructionInfo")!
        
        static let icLogo = UIImage(named: "icVectorLogo")!
        
        static let icGlobe = UIImage(named: "icGlobe")!
        static let icKeyboard = UIImage(named: "icKeyboard")!
        static let icFolder = UIImage(named: "icFolder")!
        static let icTrash = UIImage(named: "icTrash")!
        static let icTextSetup = UIImage(named: "icTextSetup")!
        static let icLanguageSetup = UIImage(named: "icLanguageSetup")!
        static let icFlip = UIImage(named: "icFlip")!
        static let icTranslateMic = UIImage(named: "icTranslateMic")!
        
        static let icTabHearing = UIImage(named: "icTabHearing")!
        static let icTabMicro = UIImage(named: "icTabMicro")!
        static let icTabSettings = UIImage(named: "icTabSettings")!
    }
    
    struct URLs {
        static let termsURL = URL(string: "https://hearing.energise.pro/terms/")!
        static let privacyPolicyURL = URL(string: "https://hearing.energise.pro/privacy/")!
        static let faqURL = URL(string: "https://hearing.energise.pro/faq/")!
        static let ourWebSiteURL = URL(string: "https://hearing.energise.pro/hearingAid/")!
        static let appStoreUrl = URL(string: "https://apps.apple.com/app/id\(CAppConstants.General.appStoreAppID)")!
        static let lupaAppStoreURL = URL(string: "itms-apps://apps.apple.com/us/app/id1571524296")!
        
        static let hearingInstructions = Bundle.main.url(forResource: "hearing_aid_instruction", withExtension: "mp4")!
        static let transcrabeInstructions = Bundle.main.url(forResource: "hearing_aid_instruction", withExtension: "mp4")!
    }
}
