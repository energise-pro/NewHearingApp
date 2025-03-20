import UIKit

struct CAppConstants {
 
    
    struct Keys {
        static let isMigratedReceipts = "isMigratedReceipts"
        static let wasUsedTrial = "kUsedTrial"
        static let launchCount = "AppLaunchCount"
        static let needsSkipSearchAdsTracking = "needsSkipSearchAdsTracking"
        static let wasPresentedCatchUp = "kPresentedCatchUp"
        static let wasConfiguredPushOffer = "kConfiguredPushOffer"
        static let wasPresentedRatingAlert = "kPresentedRatingAlert"
        static let wasSentASAInstall = "wasSentASAInstall"
        
        
        static let weeklyNoTrialSubscriptionId = "hearingaid.weekly.tier6" // тиждень без тріала 5,99
        static let yearlyWithTrialSubscriptionId = "hearingaid.yearly.trial.tier50" // рік з тріалом 49.99"
        static let lifetimeSubscriptionId = "com.hearingaid.lifetime.tier.100"
//        static let weeklySubscriptionId = "hearing_aid_weekly"
//        static let monthlySubscriptionId = "hearing_aid_monthly_new"
//        static let annualSubscriptionId = "hearing_aid_annual"
//        static let lifetimePurchase = "hearing_aid_lifetime"
//        static let yearlyNoTrialSubscriptionId = "hearing_aid_annual_no_trial"
//        static let yearlyNoTrial2SubscriptionId = "hearing_aid_annual_no_trial_29.99"
        
        
        /// One Signal Screen names
        static let catchUpScreenName = "catch_up"
        static let paywallScreenName = "paywall"
        /// OpenScreenType
        static let needsShowTranscribeOrTranslateViewController = "needsShowTranscribeOrTranslateViewController"
        static let showOpenScreenTypeViewController = "showOpenScreenTypeViewController"
    }
    
    struct Colors {
        static let lightRed: UIColor = UIColor(hex: "#FF6D6D")!
    }
    
    struct HEXStringColors {
        static let purple100: String = "#110049"
    }
    
    struct General {
        static let appStoreAppID = "6737814326"
        static let amplitudeKey = "216178a637a448232b73b4f8c617b1d0"
        static let supportEmail = "m.sulg@matu-app.online"
        static let appHudKey = "app_bpzbC3YNmvZGDYgMHxzqw3Jr698XTr"
        static let asaToolsKey = ""
        static let otterScaleHost = "https://api.aiapp3.store"
        static let otterScaleApiKey = "ifW9XE5hcJ7TyQ5J"
        
        static let countForPresentingRatingAlert = 2
    }
    struct Images {
        static let icVolumeDownUnactive = UIImage(named: "icValueDownUnactive")!
        static let icVolumeDownActive = UIImage(named: "icVolumeDownActive")!
        static let icVolumeUpActive = UIImage(named: "icVolumeUpActive")!
        static let icVolumeUpUnactive = UIImage(named: "icVolumeUpUnactive")!
        static let icAppIcon = UIImage(named: "settingsAppIcon")!
        
        static let icProSetup = UIImage(named: "setupButtonIcon")!
        static let icNoiseOff = UIImage(named: "noNoiseButtonIcon")!
        static let icNoiseOffSelected = UIImage(named: "noNoiseButtonSelectedIcon")!
        static let icStereo = UIImage(named: "stereoButtonIcon")!
        static let icStereoSelected = UIImage(named: "stereoButtonSelectedIcon")!
        static let icTemplates = UIImage(named: "templatesButtonIcon")!
        static let icInstructionInfo = UIImage(named: "infoIcon")!
        
        static let icLogo = UIImage(named: "icVectorLogo")!
        
//        static let icGlobe = UIImage(named: "icGlobe")!
//        static let icKeyboard = UIImage(named: "icKeyboard")!
        static let icFolder = UIImage(named: "saveFilledIcon")!
        static let icTrash = UIImage(named: "trashFilledIcon")!
        static let icTextSetup = UIImage(named: "textIcon")!
        static let icLanguageSetup = UIImage(named: "translateIcon")!
        static let icFlip = UIImage(named: "arrowsLeftRightIcons")!
        static let icTranslateMic = UIImage(named: "micButtonOffIcon")!
        
        static let icTabHearing = UIImage(named: "hearingTabbarIcon")!
        static let icTabMicro = UIImage(named: "transcriptionTabbarIcon")!
        static let icTabSettings = UIImage(named: "settingTabbarIcon")!
        
        static let powerOn = UIImage(named: "powerOnButtonImage")!
        static let powerOff = UIImage(named: "powerOffButtonImage")!
        
        static let speechTypeIcon = UIImage(named: "speechTypeIcon")!
        static let speechTranscribeIcon = UIImage(named: "speechTranscribeIcon")!
        static let speechTranslateIcon = UIImage(named: "speechTranslateIcon")!
        
        static let paywallBackgroundImage = UIImage(named: "paywallBackgroundImage")!
        static let paywallTopImage = UIImage(named: "paywallTopImage")!
        static let paywallCrownSmallImage = UIImage(named: "crownSmallImage")!
        
        static let paywallPerDayBackgroundImage = UIImage(named: "perDayBackgroundImage")!
        static let paywallPerDayBackgroundSelectedImage = UIImage(named: "perDayBackgroundSelectedImage")!
        static let paywallRatingImage = UIImage(named: "ratingImage")!
        static let paywallDotImage = UIImage(named: "paywallDotImage")!
        static let paywallReviewBackgroundImage = UIImage(named: "reviewBackgroundImage")!
        static let specialOffer50OffTopImage = UIImage(named: "specialOffer50OffTopImage")!
        static let specialOfferBannerBackgroundImage = UIImage(named: "specialOfferBannerBackgroundImage")!
        static let specialOfferCrownImage = UIImage(named: "specialOfferCrownImage")!
    }
    
    @MainActor
    struct URLs {
        static let termsURL = URL(string: "https://sites.google.com/energise.pro/hearingaidnews/terms-conditions")!
        static let privacyPolicyURL = URL(string: "https://sites.google.com/energise.pro/hearingaidnews/privacy-policy")!
        static let faqURL = URL(string: "https://sites.google.com/energise.pro/hearingaidnews/")!
        static let ourWebSiteURL = URL(string: "https://sites.google.com/energise.pro/hearingaidnews/home")!
        static let appStoreUrl = URL(string: "https://apps.apple.com/app/id\(CAppConstants.General.appStoreAppID)")!
        static let contactUsURL = URL(string: "https://sites.google.com/energise.pro/hearingaidnews/contact-us/?userId=" + KAppConfigServic.shared.settings.userID)!
    }
}
