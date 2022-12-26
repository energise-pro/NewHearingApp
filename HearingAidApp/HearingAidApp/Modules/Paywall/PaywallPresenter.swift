//
//  PaywallPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 18.12.2022.
//

import UIKit

protocol PaywallPresenterProtocol: AnyObject {

    var productsNames: [String] { get }
    var productsPrices: [String] { get }
    var profitTitle: String? { get }
    var infoTitles: [String] { get }
    var infoSubtitles: [String] { get }
    var trialLabelTitle: NSAttributedString { get }
    var mainProductHeaderLabelTitle: String { get }
    var switchControlTitle: String { get }
    var subscribeButtonTitle: String { get }
    var privacyPolicyButtonTitle: String { get }
    var termsOfUseButtonTitle: String { get }
    var restoreButtonTitle: String { get }
    
    func viewDidLoad()
    func didTapProductButton(at index: Int)
    func didChangeSwitchState(_ isOn: Bool)
    func didTapSubscribeButton()
    func didTapPrivacyPolicyButton()
    func didTapTermsOfUseButton()
    func didTapRestoreButton()
    func didTapCloseButton()
}

final class PaywallPresenter: PaywallPresenterProtocol {
    
    // MARK: - Public Properties
    var productsNames: [String] {
       return (isTrialEnabled ? trialProducts : fullProducts).compactMap(\.name?.capitalized)
    }
    
    var productsPrices: [String] {
       return (isTrialEnabled ? trialProducts : fullProducts).compactMap(\.skProduct?.localizedPrice)
    }
    
    var profitTitle: String? {
        return purchasesService.annualSubsciptionProfit
    }
    
    var infoTitles: [String] {
        return ["Super Boost".localized,
                "Noise Suppression".localized,
                "Speech to Text".localized]
    }
    
    var infoSubtitles: [String] {
        return ["Maximum sound concentration".localized,
                "Elimitates background noise".localized,
                "Automatic conversion of the recorded speech into text".localized]
    }
    
    var trialLabelTitle: NSAttributedString {
        let text = "3 Days Free".localized
        let range = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        return attributedText
    }
    
    var mainProductHeaderLabelTitle: String {
        return "POPULAR".localized
    }
    
    var switchControlTitle: String {
        return "Free trial enabled".localized
    }
    
    var subscribeButtonTitle: String {
        return (isTrialEnabled ? "Try Free & Subscribe" : "Subscribe").localized
    }
    
    var privacyPolicyButtonTitle: String {
        return "Privacy Policy".localized
    }
    
    var termsOfUseButtonTitle: String {
        return "Terms of use".localized
    }
    
    var restoreButtonTitle: String {
        return "Restore".localized
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view:  PaywallView
    private let purchasesService: PurchasesService
    private var products = [Product]()
    private var trialProducts: [Product] {
        products.filter { [PurchasesService.ProductID.monthlySubscriptionTrial.rawValue, PurchasesService.ProductID.annualSubscriptionTrial.rawValue].contains($0.productId) }
    }
    private var fullProducts: [Product] {
        products.filter { [PurchasesService.ProductID.monthlySubscription.rawValue, PurchasesService.ProductID.annualSubscription.rawValue].contains($0.productId) }
    }
    private var selectedProductIndex = 0
    private var isTrialEnabled = false
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: PaywallView, purchasesService: PurchasesService) {
        self.router = router
        self.view = view
        self.purchasesService = purchasesService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureLocalization()
        view.startLoading()
        purchasesService.fetchProducts(from: .premium) { [weak self] products in
            guard let self = self, let products = products, !products.isEmpty else {
                self?.view.showAlert(title: "Oops".localized,
                                      message: "Something went wrong. Please try again".localized,
                                      defaultActionTitle: "Ok".localized,
                                      destructiveActionTitle: nil)
                return
            }
            self.products = products
            DispatchQueue.main.async {
                self.view.stopLoading()
                self.view.configureLocalization()
                self.view.setProductTrialLabelsHidden(!self.isTrialEnabled)
                self.view.setProductCardsHidden(products.isEmpty)
                if self.purchasesService.wasUsedTrialPeriod {
                    self.view.setSwitchControlEnabled(false)
                    self.view.setProductTrialLabelsHidden(true)
                }
            }
        }
    }
    
    func didTapProductButton(at index: Int) {
        selectedProductIndex = index
        view.setSelectedProductView(at: index)
    }
    
    func didChangeSwitchState(_ isOn: Bool) {
        isTrialEnabled = isOn
        view.setProductTrialLabelsHidden(!isTrialEnabled)
        view.configureLocalization()
    }
    
    func didTapSubscribeButton() {
        view.startLoading()
        purchasesService.purchase(product: (isTrialEnabled ? trialProducts : fullProducts)[selectedProductIndex], from: .premium) { [weak self] isSuccess in
            guard isSuccess else {
                self?.view.stopLoading()
                self?.view.showAlert(title: "Oops".localized,
                                      message: "Something went wrong. Please try again".localized,
                                      defaultActionTitle: "Ok".localized,
                                      destructiveActionTitle: nil)
                return
            }
            DispatchQueue.main.async {
                self?.view.stopLoading()
                self?.router.performRoute(.dismiss(animated: true, completion: nil))
            }
        }
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
            self?.view.showAlert(title: (isSuccess ? "Successfully" : "Oops").localized,
                                  message:  (isSuccess ? "Purchase was successfully restored." : "Something went wrong. Please try again").localized,
                                  defaultActionTitle: "Ok".localized,
                                  destructiveActionTitle: nil)
        }
    }
    
    func didTapCloseButton() {
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
}
