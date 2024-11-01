import UIKit

final class BPaywallViewController: PMBaseViewController {

    // MARK: - @IBoutlets
    @IBOutlet private weak var purchaseContainerView: UIView!
    @IBOutlet private weak var trialContainerView: UIView!
    @IBOutlet private weak var featuresContainerView: UIView!
    
    @IBOutlet private weak var purchaseButtonLabel: UILabel!
    @IBOutlet private weak var freeTrialTitleLabel: UILabel!
    @IBOutlet private weak var trialInfoLabel: UILabel!
    @IBOutlet private weak var basicLabel: UILabel!
    @IBOutlet private weak var premiumLabel: UILabel!
    @IBOutlet private weak var headerTitle: UILabel!
    
    @IBOutlet private weak var headerImageView: UIImageView!
    
    @IBOutlet private weak var closeButton: UIButton!
    
    @IBOutlet private weak var mainSwitch: UISwitch!
    
    @IBOutlet private var bottomButtons: [UIButton]!
    
    @IBOutlet private var featureLabels: [UILabel]!
    
    @IBOutlet private var checkMarkImageViews: [UIImageView]!
    
    private var isLoading: Bool = false
    private var trialEnabled: Bool = false
    private var selectedPlan: ShopItem?
    private var subscriptionItems: [ShopItem] = []
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppHudService.shared.paywallShown()
        AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.openFromLaunch.rawValue])
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionItems.isEmpty && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        purchaseButtonLabel.textColor = .white
        trialInfoLabel.textColor = UIColor.appColor(.UnactiveButton_2)
        purchaseContainerView.backgroundColor = ThemeService.shared.activeColor
        [featuresContainerView, trialContainerView].forEach { $0?.backgroundColor = UIColor.appColor(.UnactiveButton_3) }
        closeButton.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.3)
        mainSwitch.onTintColor = ThemeService.shared.activeColor
        featureLabels.forEach { $0.textColor = UIColor.systemGray }
        checkMarkImageViews.forEach { $0.tintColor = ThemeService.shared.activeColor }
        headerImageView.tintColor = ThemeService.shared.activeColor
        
        trialContainerView.layer.borderWidth = 1.0
        trialContainerView.layer.borderColor = UIColor.appColor(.UnactiveButton_2)?.cgColor
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.purchaseContainerView.pulseAnimation()
        }
        
        localizedUI()
        changeTrialStatus(on: trialEnabled)
    }
    
    private func localizedUI() {
        ["Privacy Policy".localized(), "Restore".localized(),"Terms of Use".localized()].enumerated().forEach { bottomButtons[$0.offset].setTitle($0.element, for: .normal) }
        ["Regulated noise suppression".localized(), "Live transcribe".localized(), "Super volume boost".localized(), "Offline translation".localized(), "Type mode".localized(), "Voice changer".localized(), "Speech to Text".localized()].enumerated().forEach { featureLabels[$0.offset].text = $0.element }
        
        purchaseButtonLabel.text = "Continue".localized()
        basicLabel.text = "Basic".localized()
        premiumLabel.text = "Premium".localized()
        headerTitle.text = "Try premium version".localized()
    }
    
    private func changeTrialStatus(on value: Bool) {
        trialEnabled = value
        if value {
            let attributedString = NSMutableAttributedString(string: "Enable free trial".localized(), attributes: [.font: UIFont.systemFont(ofSize: 18.0, weight: .medium), .foregroundColor: UIColor.systemGray])
            freeTrialTitleLabel.attributedText = attributedString
            
            guard let monthlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == Constants.Keys.monthlySubscriptionId }) else {
                return
            }
            
            selectedPlan = monthlySubscriptionPlan
            let monthlyPrice = "\(monthlySubscriptionPlan.skProduct?.regularPrice ?? "")/\(monthlySubscriptionPlan.skProduct?.duration(for: .regular).components(separatedBy: " ").last ?? "")"
            let descriptionText = "First %@ free. After %@".localized(with: [monthlySubscriptionPlan.skProduct?.duration(for: .trial) ?? "", monthlyPrice])
            trialInfoLabel.text = descriptionText + "\n\("Auto-renewable, cancel anytime".localized())"
        } else {
            let attributedString = NSMutableAttributedString(string: "No sure yet?".localized(), attributes: [.font: UIFont.systemFont(ofSize: 15.0, weight: .medium), .foregroundColor: UIColor.label])
            attributedString.append(NSAttributedString(string: "\n\("Enable free trial".localized())", attributes: [.font: UIFont.systemFont(ofSize: 15.0, weight: .medium), .foregroundColor: UIColor.systemGray]))
            freeTrialTitleLabel.attributedText = attributedString
            
            let yearlyID = AppHudService.shared.abTestType == .A_2 ? Constants.Keys.yearlyNoTrialSubscriptionId : Constants.Keys.yearlyNoTrial2SubscriptionId
            guard let yearlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == yearlyID }) else {
                return
            }
            
            selectedPlan = yearlySubscriptionPlan
            trialInfoLabel.text = "Just %@".localized(with: ["\(yearlySubscriptionPlan.skProduct?.regularPrice ?? "")/\("year".localized())"]) + "\n\("Auto-renewable, cancel anytime".localized())"
        }
    }
    
    private func loadSubscriptionPlans() {
        isLoading = true
        InAppPurchasesService.shared.fetchProducts(with: .subscriptions) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.isLoading = false
            self.subscriptionItems = AppHudService.shared.experimentProducts
            DispatchQueue.main.async {
                self.changeTrialStatus(on: self.trialEnabled)
            }
        }
    }
    
    private func purchase(plan: ShopItem) {
        NativeLoaderView.showLoader(at: self.view, animated: true)
        InAppPurchasesService.shared.purchase(plan, from: .subscriptions) { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            NativeLoaderView.hideLoader(for: self.view, animated: true)
            if isSuccess {
                DispatchQueue.main.async {
                    self.closePaywall()
                }
            } else {
                self.presentErrorAlert()
            }
        }
    }
    
    private func closePaywall() {
        AppHudService.shared.paywallClosed()
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    @IBAction private func valueChanged(_ sender: UISwitch) {
        AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.trial.rawValue)_\(sender.isOn ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue)"])
        TapticEngine.impact.feedback(.medium)
        changeTrialStatus(on: sender.isOn)
    }
    
    @IBAction private func purchaseButtonAction(_ sender: UIButton) {
        guard let selectedPlan = selectedPlan else { return }
        AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.purchase.rawValue])
        TapticEngine.impact.feedback(.heavy)
        purchase(plan: selectedPlan)
    }
    
    @IBAction private func closeButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
        closePaywall()
    }
    
    @IBAction private func bottomButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        switch sender.tag {
        case 0:
            AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.privacy.rawValue])
            NavigationManager.shared.presentSafariViewController(with: Constants.URLs.privacyPolicyURL)
        case 1:
            AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.restore.rawValue])
            NativeLoaderView.showLoader(at: view, animated: true)
            InAppPurchasesService.shared.restorePurchases { [weak self] isSuccess in
                guard let self = self else { return }
                NativeLoaderView.hideLoader(for: self.view, animated: true)
                if isSuccess {
                    self.presentHidingAlert(title: "Purchases successfully restored".localized(), message: "") {
                        self.closePaywall()
                    }
                } else {
                    self.presentAlertPM(title: "Oops".localized(), message: "You have not purchases yet".localized())
                }
            }
        case 2:
            AppConfiguration.shared.analytics.track(.v2BPaywall, with: [AnalyticsAction.action.rawValue: AnalyticsAction.terms.rawValue])
            NavigationManager.shared.presentSafariViewController(with: Constants.URLs.termsURL)
        default:
            break
        }
    }
}
