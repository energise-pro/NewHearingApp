import UIKit

private struct Defaults {
        
    static var minSizeFontDescriptionPercent: CGFloat = 10
    static var maxSizeFontDescriptionPercent: CGFloat = 35

    static var minSizeFontDescription: CGFloat = 15
    static var maxSizeFontDescription: CGFloat = 20
}

final class CatchUpViewController: UMainViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var mainImageView: UIImageView!
    
    @IBOutlet private weak var mainImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightBottomImageConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var descriptionPercentLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var percentOffLabel: UILabel!
    @IBOutlet private weak var limitedOfferLabel: UILabel!
    
    @IBOutlet private weak var subscribeButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    private var offerSubscriptionPlan: ShopItem?
    private var isLoading: Bool = false
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(true, forKey: CAppConstants.Keys.wasPresentedCatchUp)
        AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        offerSubscriptionPlan == nil && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            self.heightBottomImageConstraint.constant = .appHeight * 0.6
            self.mainImageViewHeightConstraint.constant = .appHeight * 0.5
        }
    }
    
    //MARK: - Function
    private func configureUI() {
        heightBottomImageConstraint.constant = .appHeight * 0.6
        mainImageViewHeightConstraint.constant = .appHeight * 0.5
        let fontMultiplier: CGFloat = 0.07
        priceLabel.font = descriptionPercentLabel.font.withSize(min(max(.appHeight * fontMultiplier, Defaults.minSizeFontDescriptionPercent), Defaults.maxSizeFontDescriptionPercent))
        descriptionLabel.font = descriptionPercentLabel.font.withSize(min(max(.appHeight * fontMultiplier, Defaults.minSizeFontDescription), Defaults.maxSizeFontDescription))
        descriptionPercentLabel.font = descriptionPercentLabel.font.withSize(min(max(.appHeight * fontMultiplier, Defaults.minSizeFontDescription), Defaults.maxSizeFontDescription))
        
        descriptionLabel.text = "Get full access to: Super Boost, Noise Suppression, Speech to Text, Disable Ads".localized()
        limitedOfferLabel.text = "Limited Offer".localized()
        restoreButton.setTitle("Restore".localized(), for: .normal)
        termsButton.setTitle("Terms of Use".localized(), for: .normal)
        privacyButton.setTitle("Privacy Policy".localized(), for: .normal)
        subscribeButton.setTitle("Subscribe".localized(), for: .normal)
        closeButton.imageView?.tintColor = CAppConstants.Colors.lightRed
        
        subscribeButton.backgroundColor = ThemeService.shared.activeColor
        priceLabel.textColor = ThemeService.shared.activeColor.withAlphaComponent(0.85)
        descriptionLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        descriptionPercentLabel.textColor = UIColor.appColor(.UnactiveButton_2)
        mainImageView.image = UIImage(named: "icCatchUp")
    }
    
    private func loadSubscriptionPlans() {
        subscribeButton.setTitle("Loading...".localized(), for: .normal)
        isLoading = true
        InAppPurchasesService.shared.fetchProducts(with: .offer) { [weak self] items in
            guard let self = self, let offerPlan = items?.first, let regularPrice = offerPlan.skProduct?.regularPrice else {
                return
            }
            self.isLoading = false
            self.offerSubscriptionPlan = offerPlan
            DispatchQueue.main.async {
                self.subscribeButton.setTitle("Subscribe".localized(), for: .normal)
                let usedPercentages = ((100 * (offerPlan.skProduct?.introductoryPrice?.price.doubleValue ?? 1.0)) / (offerPlan.skProduct?.price.doubleValue ?? 1.0)).rounded(.up)
                let savedPercentages = 100 - Int(usedPercentages)
                self.descriptionPercentLabel.text = String(format: "for your first week You save - after per week".localized(), "\(savedPercentages)%", regularPrice)
                self.priceLabel.text = String(format: "ONLY-".localized(), offerPlan.skProduct?.introductoryPrice?.regularPrice ?? "")
                self.percentOffLabel.text = "\(savedPercentages)%" + "OFF".localized()
            }
        }
    }
    
    //MARK: - @IBAction
    @IBAction private func subscribeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        if let offerPlan = offerSubscriptionPlan {
            AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.subscribe.rawValue])
            HAppLoaderView.showLoader(at: self.view, animated: true)
            InAppPurchasesService.shared.purchase(offerPlan, from: .offer) { [weak self] isSuccess in
                guard let self = self else {
                    return
                }
                HAppLoaderView.hideLoader(for: self.view, animated: true)
                if isSuccess {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                } else {
                    self.presentErrorAlert()
                }
            }
        } else if !isLoading {
            loadSubscriptionPlans()
        }
    }
    
    @IBAction private func restoreButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.restore.rawValue])
        HAppLoaderView.showLoader(at: view, animated: true)
        InAppPurchasesService.shared.restorePurchases { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            HAppLoaderView.hideLoader(for: self.view, animated: true)
            if isSuccess {
                self.presentHidingAlert(title: "Purchases successfully restored".localized(), message: "") {
                    self.dismiss(animated: true)
                }
            } else {
                self.presentAlertPM(title: "Oops".localized(), message: "You have not purchases yet".localized())
            }
        }
    }
    
    @IBAction private func termsButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.terms.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
    }
    
    @IBAction private func privacyButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.privacy.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
    }
    
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2CatchUp, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        dismiss(animated: true)
    }
}
