////
////  AdvertisingService.swift
////  AdvertisingService
////
////  Created by Misha Petrus on 18.08.2021.
////
//
//import UIKit
//import CleverAdsSolutions
//import AppTrackingTransparency
//import AdSupport
//
//typealias AdvertisingServiceSuccessCompletion = (Bool) -> ()
//
//final class AdvertisingService {
//    
//    // MARK: - Properties
//    static var shared: AdvertisingService = AdvertisingService()
//    
//    private var isAdEnabled: Bool {
//        if InAppPurchasesService.shared.isPremium {
//            return false
//        } else {
//            return true
//        }
//    }
//    
//    private var mediationManager: CASMediationManager?
//    private var appOpenManager: CASAppOpen?
//    private var currentAdvertisingType: CleverAdsSolutions.CASType = .none
//    
//    // MARK: - Internal methods
//    func run(completion: AdvertisingServiceSuccessCompletion? = nil) {
//        guard isAdEnabled else {
//            completion?(false)
//            return
//        }
//        
//        func initializeSDK() {
//            mediationManager = CAS.create(managerID: Constants.General.appStoreAppID)
//            mediationManager?.adLoadDelegate = self
//            appOpenManager = CASAppOpen.create(managerId: Constants.General.appStoreAppID)
//            appOpenManager?.contentCallback = self
//        }
//        
//        
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                DispatchQueue.main.async {
//                    completion?(status == .authorized)
//                    initializeSDK()
//                }
//            }
//        } else {
//            completion?(true)
//            initializeSDK()
//        }
//    }
//    
//    func presentInterstitialAdvertising() {
//        guard isAdEnabled, let topViewController = UIApplication.shared.topMostViewController(), !(topViewController is PaywallViewController) else {
//            return
//        }
//        
//        currentAdvertisingType = .interstitial
//        
//        if mediationManager?.isAdReady(type: .interstitial) == true {
//            AppConfigService.shared.analytics.track(action: .interstitialAd, with: [AnalyticsAction.action.rawValue: AnalyticsAction.show.rawValue])
//            mediationManager?.presentInterstitial(fromRootViewController: topViewController, callback: self)
//        } else {
//            mediationManager?.loadInterstitial()
//        }
//    }
//    
//    func presentAppOpenAdvertising() {
//        guard isAdEnabled, let topViewController = UIApplication.shared.topMostViewController(), !(topViewController is PaywallViewController) else {
//            return
//        }
//        AppConfigService.shared.analytics.track(action: .appOpenAd, with: [AnalyticsAction.action.rawValue: AnalyticsAction.show.rawValue])
//        appOpenManager?.loadAd(orientation: .portrait) { appOpenManager, error in
//            guard error == nil else {
//                return
//            }
//            appOpenManager.present(fromRootViewController: topViewController)
//        }
//    }
//}
//
//// MARK: - CASCallback
//extension AdvertisingService: CASCallback {
//    
//    func didClosedAd() { }
//}
//
//// MARK: - CASLoadDelegate
//extension AdvertisingService: CASLoadDelegate {
//    
//    func onAdLoaded(_ adType: CleverAdsSolutions.CASType) {
//        switch currentAdvertisingType {
//        case .interstitial:
//            presentInterstitialAdvertising()
//        default:
//            break
//        }
//    }
//    
//    func onAdFailedToLoad(_ adType: CleverAdsSolutions.CASType, withError error: String?) { }
//}
