import OneSignal

protocol OneSignalProtocol {
    
}

extension OneSignalProtocol {
    
    var notificationPermissionStatus: OSNotificationPermission {
        return OneSignal.getDeviceState().notificationPermissionStatus
    }
    
    func showPushNotificationsAlert(_ fallbackToSettings: Bool = true) {
        OneSignal.promptForPushNotifications(userResponse: { accepted  in
            AppConfiguration.shared.analytics.track(GAppAnalyticActions.v2Notification, with: [GAppAnalyticActions.action.rawValue: accepted ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue])
        }, fallbackToSettings: fallbackToSettings)
    }
}
