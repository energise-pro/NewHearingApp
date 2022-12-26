//
//  OnboardingPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import Foundation


protocol OnboardingPresenterProtocol: AnyObject {
    
    var numberOfScreens: Int { get }
    
    func viewDidLoad()
    func viewDidAppear()
    func didTapPrivacyPolicyButton()
    func didTapTermsOfUseButton()
    func didTapRestoreButton()
    func didTapContinueButton()
    func didTapCloseButton()
    func configure(cell: OnboardingCollectionViewCell, for index: Int)
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
    
    // MARK: - Public Properties
    var numberOfScreens: Int {
        return screens.count
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: OnboardingView
    private let purchasesService: PurchasesService
    private var screens: [OnboardingScreen] = [.regulatedNoiseSuppression, .superVolumeBoost, .speechRecognition, .aboutFreeTrial]
    private var currentScreenIndex = 0
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: OnboardingView, purchasesService: PurchasesService) {
        self.router = router
        self.view = view
        self.purchasesService = purchasesService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUI()
        view.configureLocalization()
    }
    
    func viewDidAppear() {
        purchasesService.requestTrackingTransparencyAuthorization()
    }
    
    func didTapPrivacyPolicyButton() {
        router.performRoute(.privacyPolicy)
    }
    
    func didTapTermsOfUseButton() {
        router.performRoute(.termsOfUse)
    }
     
    func didTapRestoreButton() {
        view.startLoading()
        purchasesService.restorePurchases { [weak self] isSuccess in
            self?.view.stopLoading()
            self?.view.showAlert(title: "Purchases Service".localized,
                                  message:  (isSuccess ? "Purchase was successfully restored." : "Something was wrong. Please try again later").localized,
                                  defaultActionTitle: "Ok".localized,
                                  destructiveActionTitle: nil)
        }
    }
    
    func didTapContinueButton() {
        guard currentScreenIndex < screens.count - 1 else {
            router.performRoute(.paywall)
            return
        }
        view.setContinueButtonEnabled(false)
        currentScreenIndex += 1
        if currentScreenIndex == numberOfScreens - 1 {
            fetchPaywallInfo()
        } else {
            view.scrollToItem(at: currentScreenIndex)
            view.setContinueButtonEnabled(true)
        }
    }
    
    func didTapCloseButton() {
        router.performRoute(.main)
    }
    
    func configure(cell: OnboardingCollectionViewCell, for index: Int) {
        if index < numberOfScreens - 1 {
            cell.configure(for: screens[index],
                           numberOfScreens: numberOfScreens)
        } else {
            cell.configure(for: .aboutFreeTrial, price: purchasesService.monthlySubscriptionPrice)
        }
    }
    
    // MARK: - Private Methods
    private func fetchPaywallInfo() {
        view.startLoading()
        purchasesService.fetchMonthlySubscriptionInfo(from: .premium) { [weak self] in
            self?.view.stopLoading()
            self?.view.setContinueButtonEnabled(true)
            self?.view.scrollToItem(at: self?.currentScreenIndex ?? 0)
            self?.view.showCloseButton()
        }
    }
}
