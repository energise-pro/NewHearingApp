//
//  SceneDelegate.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 13.12.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Public Properties
    var window: UIWindow?
    
    // MARK: - Private Properties
    private lazy var applicationRouter = ApplicationRouter(window: window!, serviceProvider: serviceProvider)
    private var serviceProvider: ServiceProdiver {
        return (UIApplication.shared.delegate as! AppDelegate).serviceProvider
    }
    
    // MARK: - Public Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        applicationRouter.start()
    }
}

