import OneSignal

protocol OneSignalProtocol {
    
}

extension OneSignalProtocol {
    
    var notificationPermissionStatus: OSNotificationPermission {
        return OneSignal.getDeviceState().notificationPermissionStatus
    }
    
    func showPushNotificationsAlert(_ fallbackToSettings: Bool = true) {
        OneSignal.promptForPushNotifications(userResponse: { accepted  in
            AppConfigService.shared.analytics.track(AnalyticsAction.v2Notification, with: [AnalyticsAction.action.rawValue: accepted ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue])
        }, fallbackToSettings: fallbackToSettings)
    }
}
