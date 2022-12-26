//
//  AppDelegate.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 13.12.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Private Properties
    let serviceProvider: ServiceProdiver = Application()
    
    // MARK: - Object Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        serviceProvider.didFinishLaunchingWithOptions(launchOptions: launchOptions)
        return true
    }
}
