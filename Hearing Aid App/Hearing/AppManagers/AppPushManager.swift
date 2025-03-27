//
//  AppPushManager.swift
//  Hearing Aid App

import Foundation
import UIKit
import UserNotifications

final class AppPushManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = AppPushManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Push Authorization Error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    @MainActor public func showLimitedTimeSpecialOfferNotificationWithIfNeed(completion: ((Bool) -> Void)? = nil) {
        let pushSpecialClose = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Push_special_close.rawValue).boolValue
        guard pushSpecialClose, !TInAppService.shared.isPremium, let topViewController = AppsNavManager.shared.topViewController, !(topViewController is NewOnboardingViewController) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Limited-time offer!".localized() + " 🔊"
        content.body = "Enjoy better hearing —50% off for you now!".localized() + " 🎁"
        content.userInfo = ["navigateTo": "specialOffer"]
        content.badge = 0
        content.sound = .default
        
        let date = Date(timeIntervalSinceNow: 3)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "limited-time-offer", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: ["limited-time-offer"])
        center.add(request) { error in
            completion?(error != nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let navigateTo = userInfo["navigateTo"] as? String, navigateTo == "specialOffer" {
            DispatchQueue.main.async {
                AppsNavManager.shared.presentSpecialOffer(1, with: .openFromNotification)
            }
        }
        completionHandler()
    }
}
