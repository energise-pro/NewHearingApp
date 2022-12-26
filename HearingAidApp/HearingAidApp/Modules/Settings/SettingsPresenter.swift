//
//  SettingsPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 20.12.2022.
//

protocol SettingsPresenterProtocol: AnyObject {
    
    var title: String { get }
    var cancelSubscriptionButtonTitle: String { get }
    var restorePurchaseButtonTitle: String { get }
    var supportAndContactsUsButtonTitle: String { get }
    
    func viewDidLoad()
    func didTapCancelSubscriptionButton()
    func didTapRestorePurchaseButton()
    func didTapSupportAndContactUsButton()
}

final class SettingsPresenter: SettingsPresenterProtocol {
    
    // MARK: - Public Properties
    var title: String {
        return "Settings".localized
    }
    
    var cancelSubscriptionButtonTitle: String {
        return "Cancel subscription".localized
    }
    
    var restorePurchaseButtonTitle: String {
        return "Restore Purchase".localized
    }
    
    var supportAndContactsUsButtonTitle: String {
        return "Support & Contact Us".localized
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: SettingsView
    private let purchasesService: PurchasesService
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: SettingsView, purchasesService: PurchasesService) {
        self.router = router
        self.view = view
        self.purchasesService = purchasesService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureLocalization()
    }
    
    func didTapCancelSubscriptionButton() {
        router.performRoute(.cancelSubscription)
    }
    
    func didTapRestorePurchaseButton() {
        view.startLoading()
        purchasesService.restorePurchases { [weak self] isSuccess in
            self?.view.stopLoading()
            isSuccess ? self?.showSuccessAlert() : self?.showFailureAlert()
        }
    }
    
    func didTapSupportAndContactUsButton() {
        router.performRoute(.supportAndContactUs)
    }
    
    // MARK: - Private Methods
    private func showSuccessAlert() {
        view.showAlert(title: "Purchases successfully restored".localized,
                        message: "",
                        defaultActionTitle: "Ok".localized,
                        destructiveActionTitle: nil)
    }
    
    private func showFailureAlert() {
        view.showAlert(title: "Oops".localized,
                        message: "You have not purchases yet".localized,
                        defaultActionTitle: "Ok".localized,
                        destructiveActionTitle: nil)
    }
}
