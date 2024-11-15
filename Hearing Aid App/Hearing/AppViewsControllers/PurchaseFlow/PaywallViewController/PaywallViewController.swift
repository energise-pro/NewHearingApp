import UIKit


final class PaywallViewController: UIViewController {
    
    //MARK: - @IBoutlets
    @IBOutlet private weak var purchaseContainerView: UIView!
    @IBOutlet private weak var purchaseButtonLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleYearlyButtonLabel: UILabel!
    @IBOutlet private weak var titleWeeklyButtonLabel: UILabel!
    @IBOutlet private weak var priceWeeklyButtonLabel: UILabel!
    @IBOutlet private weak var priceYearlyButtonLabel: UILabel!
    @IBOutlet private weak var mostPopularLabel: UILabel!
    
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var yearlySubscribeButton: UIButton!
    @IBOutlet private weak var weeklySubscribeButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var redeemPromocodeButton: UIButton!
    
    @IBOutlet private weak var containerButtonYearly: UIView!
    @IBOutlet private weak var containerButtonWeekly: UIView!
    @IBOutlet private weak var mostPopularContainerView: UIView!
    
    @IBOutlet private weak var monthlySubscribeButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var heightSubscribeButtonConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var volumeBoostFeature: RadialGradientView!
    @IBOutlet weak var noNoiseFeature: RadialGradientView!
    @IBOutlet weak var soundCustomizationFeature: RadialGradientView!
    
    //MARK: - Properties
    private var typeScreen: ВTypPwlScreen
    private var scaleYearlyButton = true
    private var isLoading: Bool = false
    private var subscriptionItems: [ShopItem] = []
    private var openAction: GAppAnalyticActions
    private var selectedPlan: ShopItem?
    
    //MARK: - Init
    init(typeScreen: ВTypPwlScreen, openAction: GAppAnalyticActions) {
        self.typeScreen = typeScreen
        self.openAction = openAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        EApphudServiceAp.shared.paywallShown()
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: openAction.rawValue])
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionItems.isEmpty && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    //MARK: - Functions
    private func configureUI() {
        closeButton.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.3)
        
        purchaseButtonLabel.textColor = UIColor.appColor(.White100)
        purchaseContainerView.backgroundColor = UIColor.appColor(.Red100)
        
        containerButtonYearly.layer.cornerRadius = 12
        containerButtonYearly.layer.borderWidth = 1
        
        containerButtonWeekly.layer.cornerRadius = 12
        containerButtonWeekly.layer.borderWidth = 1
        
        mostPopularContainerView.backgroundColor = UIColor.appColor(.Red100)
        mostPopularLabel.layer.cornerRadius = 14
        
        volumeBoostFeature.configure(withText: "Super volume boost".localized(), image: UIImage(named: "featuresBoostIcon"))
        noNoiseFeature.configure(withText: "Noise Suppression".localized(), image: UIImage(named: "featuresNoiseIcon"))
        soundCustomizationFeature.configure(withText: "Full Sound Customization".localized(), image: UIImage(named: "featuresSetupIcon"))
        
        selectProductView(containerButtonYearly)
        unselectProductView(containerButtonWeekly)
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1.0
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            self?.containerButtonYearly.pulseAnimation()
//        }
        
        localizedUI()
    }
    
    private func localizedUI() {
        purchaseButtonLabel.text = "Try Free & Subscribe".localized()
        mostPopularLabel.text = "Most popular".localized()
        titleYearlyButtonLabel.text = "3 Days Free".localized()
        titleWeeklyButtonLabel.text = "1 Week".localized()
        titleLabel.text = "Get Full Access".localized()
        privacyButton.setTitle("Privacy Policy".localized(), for: .normal)
        termsButton.setTitle("Terms of Use".localized(), for: .normal)
        restoreButton.setTitle("Restore".localized(), for: .normal)
//        redeemPromocodeButton.setTitle("Redeem code", for: .normal)
    }
    
    private func loadSubscriptionPlans() {
        TInAppService.shared.fetchProducts(with: .subscriptions) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.subscriptionItems = EApphudServiceAp.shared.experimentProducts
            DispatchQueue.main.async {
                self.configureUIAfterSubscriptionsLoading()
            }
        }
    }
    
    private func configureUIAfterSubscriptionsLoading() {
        guard let yearlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.yearlyWithTrialSubscriptionId }),
              let weeklySubscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.weeklyNoTrialSubscriptionId }) else {
            return
        }
        
        let daysFree = yearlySubscriptionPlan.skProduct?.duration(for: .trial)
        if let daysFree = daysFree {
            titleYearlyButtonLabel.text = daysFree + " " + "free".localized()
        } else {
            titleYearlyButtonLabel.text = "3 Days Free".localized()
        }
        titleWeeklyButtonLabel.text = weeklySubscriptionPlan.skProduct?.duration(for: .regular) ?? "1 Week".localized()

        let weeklyPriceForYearlyPlan = ((yearlySubscriptionPlan.skProduct?.price.doubleValue ?? 1.0) / 52.0).rounded(toPlaces: 2)
        priceYearlyButtonLabel.text = "Then %@/year (only %@%@/week)".localized(with: [yearlySubscriptionPlan.skProduct?.regularPrice ?? "", weeklySubscriptionPlan.skProduct?.priceLocale.currencySymbol ?? "$", weeklyPriceForYearlyPlan])
        priceWeeklyButtonLabel.text = weeklySubscriptionPlan.skProduct?.regularPrice
        
        selectedPlan = yearlySubscriptionPlan
    }
    
    private func purchase(plan: ShopItem) {
        HAppLoaderView.showLoader(at: self.view, animated: true)
        TInAppService.shared.purchase(plan, from: .subscriptions) { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            HAppLoaderView.hideLoader(for: self.view, animated: true)
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
        EApphudServiceAp.shared.paywallClosed()
        dismiss(animated: true)
    }
    
    private func selectProductView(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.backgroundColor = UIColor.appColor(.Red100)?.withAlphaComponent(0.24)
        }
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = view.layer.borderColor
        borderColorAnimation.toValue = UIColor.appColor(.Red100)?.cgColor
        borderColorAnimation.duration = 0.3
        view.layer.add(borderColorAnimation, forKey: "borderColor")
        view.layer.borderColor = UIColor.appColor(.Red100)?.cgColor
        
        if view == containerButtonWeekly {
            titleWeeklyButtonLabel.textColor = UIColor.appColor(.White100)
            priceWeeklyButtonLabel.textColor = UIColor.appColor(.White100)
        } else {
            titleYearlyButtonLabel.textColor = UIColor.appColor(.White100)
            priceYearlyButtonLabel.textColor = UIColor.appColor(.White100)
        }
    }

    private func unselectProductView(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.backgroundColor = UIColor.clear
        }
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = view.layer.borderColor
        borderColorAnimation.toValue = UIColor.appColor(.Red100)?.withAlphaComponent(0.3).cgColor
        borderColorAnimation.duration = 0.3
        view.layer.add(borderColorAnimation, forKey: "borderColor")
        view.layer.borderColor = UIColor.appColor(.Red100)?.withAlphaComponent(0.3).cgColor
        
        if view == containerButtonWeekly {
            titleWeeklyButtonLabel.textColor = UIColor.appColor(.Grey100)
            priceWeeklyButtonLabel.textColor = UIColor.appColor(.Grey100)
        } else {
            titleYearlyButtonLabel.textColor = UIColor.appColor(.Grey100)
            priceYearlyButtonLabel.textColor = UIColor.appColor(.Grey100)
        }
    }
    
    //MARK: - @IBAction
    @IBAction func purchaseButtonAction(_ sender: UIButton) {
        guard let selectedPlan = selectedPlan else {
            return
        }
        TapticEngine.impact.feedback(.heavy)
        purchase(plan: selectedPlan)
    }
    
    @IBAction private func weeklySubscribeButtonAction(_ sender: UIButton) {
        guard let subscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.weeklyNoTrialSubscriptionId }) else {
            return
        }
        selectedPlan = subscriptionPlan
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.purchase.rawValue)_\(subscriptionPlan.productId)"])
        
        selectProductView(containerButtonWeekly)
        unselectProductView(containerButtonYearly)
        UIView.transition(with: purchaseButtonLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.purchaseButtonLabel.text = "Continue".localized()
        }, completion: nil)
    }
    
    @IBAction private func yearlySubscribeButtonAction(_ sender: UIButton) {
        guard let subscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.yearlyWithTrialSubscriptionId }) else {
            return
        }
        selectedPlan = subscriptionPlan
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.purchase.rawValue)_\(subscriptionPlan.productId)"])
        
        selectProductView(containerButtonYearly)
        unselectProductView(containerButtonWeekly)
        UIView.transition(with: purchaseButtonLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.purchaseButtonLabel.text = "Try Free & Subscribe".localized()
        }, completion: nil)
    }
    
    @IBAction private func restoreButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.restore.rawValue])
        HAppLoaderView.showLoader(at: view, animated: true)
        TInAppService.shared.restorePurchases { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            HAppLoaderView.hideLoader(for: self.view, animated: true)
            if isSuccess {
                self.presentHidingAlert(title: "Purchases successfully restored".localized(), message: "") {
                    self.closePaywall()
                }
            } else {
                self.presentAlertPM(title: "Oops".localized(), message: "You have not purchases yet".localized())
            }
        }
    }
    
    @IBAction private func privacyButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.privacy.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
    }
    
    @IBAction private func termsButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.terms.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
    }
    
    @IBAction private func closeButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        typeScreen == .trial ? AppsNavManager.shared.presentCatchUpAfter(60.0) : Void()
        closePaywall()
    }
    
    @IBAction private func redeemPromocodeAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        KAppConfigServic.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.redeem.rawValue])
        TInAppService.shared.presentRedeemScreen()
    }
}

private struct Defaults {
    
    static let minSizeFontTitleLabel: CGFloat = 16
    static let maxSizeFontTitleLabel: CGFloat = 40
    
    static let minSizeFontSubTitleLabel: CGFloat = 14
    static let maxSizeFontSubTitleLabel: CGFloat = 26
    
    static let minSizeFontDescriptionPriceLabel: CGFloat = 14
    static let maxSizeFontDescriptionPriceLabel: CGFloat = 18
    
    static let minSizeDescriptionLabels: CGFloat = 12
    static let maxSizeDescriptionLabels: CGFloat = 18
    
    static let minSubtitleLabelBottom: CGFloat = 10
    static let maxSubtitleLabelBottom: CGFloat = 40
}
