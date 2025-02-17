import UIKit

final class DBPaywlApViewController: PMUMainViewController {

    // MARK: - @IBoutlets
    @IBOutlet private weak var purchaseContainerView: UIView!
    @IBOutlet private weak var purchaseButtonLabel: UILabel!
    @IBOutlet private weak var headerTitle: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private var bottomButtons: [UIButton]!
    @IBOutlet weak var trialTitle: UILabel!
    @IBOutlet weak var trialDescription: UILabel!
    
    private var isLoading: Bool = false
    private var trialEnabled: Bool = false
    private var selectedPlan: ShopItem?
    private var subscriptionItems: [ShopItem] = []
    private var analyticProperties: [String: String] = [:]
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        EApphudServiceAp.shared.paywallShown()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionItems.isEmpty && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        purchaseButtonLabel.textColor = UIColor.appColor(.White100)
        purchaseContainerView.backgroundColor = UIColor.appColor(.Red100)
        closeButton.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.3)
        headerImageView.tintColor = AThemeServicesAp.shared.activeColor
        localizedUI()
        
        let closeButtonTimeInterval = Int(truncating: KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Xtime_HA_PT_2_pw_default_ob_1.rawValue).numberValue)
        Timer.scheduledTimer(withTimeInterval: TimeInterval(closeButtonTimeInterval), repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1.0
            }
        }
    }
    
    private func localizedUI() {
        ["Privacy Policy".localized(), "Terms of Use".localized(), "Restore".localized(),].enumerated().forEach { bottomButtons[$0.offset].setTitle($0.element, for: .normal) }
        headerTitle.text = "Get Unlimited Access".localized()
    }
    
    private func updateSelectedPlan() {
        guard let yearlySubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "year"}) else {
            return
        }
        
        let daysFree = yearlySubscriptionPlan.skProduct?.duration(for: .trial)
        if let daysFree = daysFree, !daysFree.isEmpty {
            trialTitle.text = daysFree + " " + "free".localized()
            let weeklyPriceForYearlyPlan = ((yearlySubscriptionPlan.skProduct?.price.doubleValue ?? 1.0) / 52.0).rounded(toPlaces: 2)
            trialDescription.text = "Then %@/year (only %@/week)".localized(with: [yearlySubscriptionPlan.skProduct?.regularPrice ?? "", yearlySubscriptionPlan.skProduct?.regularPrice(for: weeklyPriceForYearlyPlan) ?? ""])
            purchaseButtonLabel.text = "Try Free & Subscribe".localized()
        } else {
            trialTitle.text = yearlySubscriptionPlan.skProduct?.duration(for: .regular) ?? "1 Year".localized()
            trialDescription.text = yearlySubscriptionPlan.skProduct?.regularPrice
            purchaseButtonLabel.text = "Continue".localized()
        }
        
        selectedPlan = yearlySubscriptionPlan
    }
    
    private func loadSubscriptionPlans() {
        let placementIdentifier = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Price_HA_PT_2_pw_default_ob_1.rawValue).stringValue ?? "plc"
        isLoading = true
        TInAppService.shared.fetchProducts(with: placementIdentifier) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.isLoading = false
            self.subscriptionItems = items
            self.updateSelectedPlan()
        }
        
        analyticProperties[GAppAnalyticActions.source.rawValue] = GAppAnalyticActions.sourceOb.rawValue
        analyticProperties["pwl_version"] = "pw_default_ob_1"
        analyticProperties["offer"] = placementIdentifier
        KAppConfigServic.shared.analytics.track(.paywallSeen, with: analyticProperties)
    }
    
    private func purchase(plan: ShopItem) {
        KAppConfigServic.shared.analytics.track(.purchaseCheckout, with: analyticProperties)
        HAppLoaderView.showLoader(at: self.view, animated: true)
        TInAppService.shared.purchase(plan, from: .subscriptions) { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            HAppLoaderView.hideLoader(for: self.view, animated: true)
            if isSuccess {
                KAppConfigServic.shared.analytics.track(.purchaseActivate, with: analyticProperties)
                DispatchQueue.main.async {
                    self.closePaywall()
                }
            } else {
                self.presentErrorAlert()
            }
        }
    }
    
    private func closePaywall() {
        EApphudServiceAp.shared.paywallClosed()
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction private func purchaseButtonAction(_ sender: UIButton) {
        guard let selectedPlan = selectedPlan else { return }
        TapticEngine.impact.feedback(.heavy)
        purchase(plan: selectedPlan)
    }
    
    @IBAction private func closeButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        KAppConfigServic.shared.analytics.track(.paywallPassed, with: analyticProperties)
        closePaywall()
    }
    
    @IBAction private func bottomButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        switch sender.tag {
        case 0:
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
        case 1:
            HAppLoaderView.showLoader(at: view, animated: true)
            TInAppService.shared.restorePurchases { [weak self] isSuccess in
                guard let self = self else { return }
                HAppLoaderView.hideLoader(for: self.view, animated: true)
                if isSuccess {
                    self.presentHidingAlert(title: "Purchases successfully restored".localized(), message: "") {
                        self.closePaywall()
                    }
                } else {
                    self.presentAlertPM(title: "Oops".localized(), message: "You have not purchases yet".localized())
                }
            }
        case 2:
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
        default:
            break
        }
    }
}
