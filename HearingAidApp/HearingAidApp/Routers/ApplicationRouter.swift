//
//  ApplicationRouter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit
import MessageUI

enum ApplicationRoute {
    
    // MARK: - Cases
    case onboarding
    case privacyPolicy
    case termsOfUse
    case microphonePermission
    case speechRecognitionPermission
    case headphonesConnection
    case paywall
    case main
    case cancelSubscription
    case supportAndContactUs
    case languagesList(dismissAction: ((Locale) -> Void)?)
    case dismiss(animated: Bool, completion: (() -> Void)?)
}

protocol ApplicationRouterDelegate: AnyObject {
    
    func performRoute(_ route: ApplicationRoute)
}

final class ApplicationRouter: NSObject, Router {

    // MARK: - Private Properties
    private let window: UIWindow
    private let serviceProvider: ServiceProdiver
    private lazy var viewFactory: ViewFactoryProtocol = ViewFactory()
    private lazy var presenterFactory: PresenterFactoryProtocol = PresenterFactory(router: self,
                                                                                   serviceProvider: serviceProvider)
    private lazy var tabBarController: UITabBarController = UITabBarController()
    private var topViewController: UIViewController? {
        if var topViewController = window.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        }
        return nil
    }
    
    @UserDefault("isFirstLaunch")
    private var isFirstLaunch = true
    
    // MARK: - Object Lifecycle
    init(window: UIWindow, serviceProvider: ServiceProdiver) {
        self.window = window
        self.serviceProvider = serviceProvider
    }
    
    // MARK: - Public Methods
    func start() {
        if isFirstLaunch {
            showOnboarding()
            isFirstLaunch = false
        } else {
            showMain()
        }
    }
    
    // MARK: - Private Methods
    private func setRootViewController(_ viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    private func presentViewContoller(_ viewController: UIViewController, animated: Bool = true) {
        topViewController?.present(viewController, animated: animated)
    }
    
    private func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.dismiss(animated: animated, completion: completion)
    }
    
    private func showOnboarding() {
        let view = viewFactory.makeOnboardingView()
        let presenter = presenterFactory.makeOnboardingPresenter(for: view)
        view.setPresenter(presenter)
        setRootViewController(view.presentableViewController)
    }
    
    private func showMain(animated: Bool = false) {
        let hearingAidView = viewFactory.makeHearingAidView()
        let hearingAidPresenter = presenterFactory.makeHearingAidPresenter(for: hearingAidView)
        hearingAidView.setPresenter(hearingAidPresenter)
        
        let speechRecognitionView = viewFactory.makeSpeechRecognitionView()
        let speechRecognitionPresenter = presenterFactory.makeSpeechRecognitionPresenter(for: speechRecognitionView)
        speechRecognitionView.setPresenter(speechRecognitionPresenter)
        
        let typeView = viewFactory.makeTypeView()
        let typePresenter = presenterFactory.makeTypePresenter(for: typeView)
        typeView.setPresenter(typePresenter)
        
        let settingsView = viewFactory.makeSettingsView()
        let settingsPresenter = presenterFactory.makeSettingsPresenter(for: settingsView)
        settingsView.setPresenter(settingsPresenter)
        
        tabBarController.setViewControllers([hearingAidView, speechRecognitionView, typeView, settingsView].map(\.presentableViewController), animated: animated)
        setRootViewController(tabBarController)
    }
    
    private func showPermission(for permissionType: PermissionType) {
        let view = viewFactory.makePermissionsViwe()
        let presenter = presenterFactory.makePermissionPresenter(for: view, with: permissionType)
        view.setPresenter(presenter)
        view.presentableViewController.modalTransitionStyle = .coverVertical
        view.presentableViewController.modalPresentationStyle = .fullScreen
        presentViewContoller(view.presentableViewController)
    }
    
    private func showHeadphonesConnection() {
        let view = viewFactory.makeHeadphonesConnectionView()
        let presenter = presenterFactory.makeHeadphonesConnectionPresenter(for: view)
        view.setPresenter(presenter)
        view.presentableViewController.modalTransitionStyle = .coverVertical
        view.presentableViewController.modalPresentationStyle = .fullScreen
        presentViewContoller(view.presentableViewController)
    }
    
    private func showPaywall() {
        let view = viewFactory.makePaywallView()
        let presenter = presenterFactory.makePaywallPresenter(for: view)
        view.setPresenter(presenter)
        view.presentableViewController.modalTransitionStyle = .coverVertical
        view.presentableViewController.modalPresentationStyle = .fullScreen
        if window.rootViewController !== tabBarController {
            showMain()
        }
        presentViewContoller(view.presentableViewController)
    }
    
    private func showPrivacyPolicy() {
        let view = viewFactory.makeWebView()
        let presenter = presenterFactory.makeWebPresenter(for: view,
                                                          url: Constants.Link.privacyPolicy,
                                                          title: "Privacy Policy".localized)
        view.setPresenter(presenter)
        presentViewContoller(view.presentableViewController)
    }
    
    private func showTermsOfUse() {
        let view = viewFactory.makeWebView()
        let presenter = presenterFactory.makeWebPresenter(for: view,
                                                          url: Constants.Link.termsOfUse,
                                                          title: "Terms of use".localized)
        view.setPresenter(presenter)
        presentViewContoller(view.presentableViewController)
    }
    
    private func showCancelSubscription() {
        guard MFMailComposeViewController.canSendMail() else { return }
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setToRecipients([Constants.Support.email])
        viewController.setSubject(Constants.Support.cancelSubscriptionTitle)
        viewController.setMessageBody(Constants.Support.cancelSubscriptionBody, isHTML: true)
        topViewController?.present(viewController, animated: true)
    }
    
    private func showSupportAndContactUs() {
        guard MFMailComposeViewController.canSendMail() else { return }
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setToRecipients([Constants.Support.email])
        viewController.setSubject(Constants.Support.supportTitle)
        viewController.setMessageBody(Constants.Support.supportBody, isHTML: true)
        topViewController?.present(viewController, animated: true)
    }
    
    private func showLanguagesList(_ dismissAction: ((Locale) -> Void)? = nil) {
        let view = viewFactory.makeLanguagesListView()
        let presenter = presenterFactory.makeLanguagesListPresenter(for: view,
                                                                    locales: serviceProvider.speechRecognitionService.supportedLocales())
        presenter.dismissAction = dismissAction
        view.setPresenter(presenter)
        presentViewContoller(view.presentableViewController)
    }
}

// MARK: - ApplicationRouterDelegate
extension ApplicationRouter: ApplicationRouterDelegate {
    
    func performRoute(_ route: ApplicationRoute) {
        switch route {
        case .onboarding:
            showOnboarding()
        case .privacyPolicy:
            showPrivacyPolicy()
        case .termsOfUse:
            showTermsOfUse()
        case .microphonePermission:
            showPermission(for: .microphoneUsage)
        case .speechRecognitionPermission:
            showPermission(for: .speechRecognition)
        case .headphonesConnection:
            showHeadphonesConnection()
        case .paywall:
            showPaywall()
        case .main:
            showMain()
        case .cancelSubscription:
            showCancelSubscription()
        case .supportAndContactUs:
            showSupportAndContactUs()
        case let .languagesList(dismissAction):
            showLanguagesList(dismissAction)
        case let .dismiss(animated, completion):
            dismiss(animated: animated, completion: completion)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ApplicationRouter: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
