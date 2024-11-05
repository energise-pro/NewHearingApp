import UIKit


final class PaywallViewController: UIViewController {
    
    //MARK: - @IBoutlets
    @IBOutlet private weak var boostLabel: UILabel!
    @IBOutlet private weak var bostSubTitleLabel: UILabel!
    @IBOutlet private weak var noiseLabel: UILabel!
    @IBOutlet private weak var noiseSubTitleLabel: UILabel!
    @IBOutlet private weak var speechLabel: UILabel!
    @IBOutlet private weak var speechSubTitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var descriptionPriceLabel: UILabel!
    @IBOutlet private weak var titleYearlyButtonLabel: UILabel!
    @IBOutlet private weak var titleMonthlyButtonLabel: UILabel!
    @IBOutlet private weak var priceMonthlyButtonLabel: UILabel!
    @IBOutlet private weak var priceYearlyButtonLabel: UILabel!
    @IBOutlet private weak var descriptionYearlyButtonLabel: UILabel!
    @IBOutlet private weak var mostPopularLabel: UILabel!
    
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var yearlySubscribeButton: UIButton!
    @IBOutlet private weak var monthlySubscribeButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var redeemPromocodeButton: UIButton!
    
    @IBOutlet private weak var containerButtonYearly: UIView!
    @IBOutlet private weak var containerButtonMonthly: UIView!
    @IBOutlet private weak var mostPopularContainerView: UIView!
    
    @IBOutlet private weak var yearlyButtonSubscribeBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var priceDescriptionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var subtitleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var monthlySubscribeButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var verticalSpacingViewsConstraints: [NSLayoutConstraint]!
    @IBOutlet private var verticalSpacingsLabelsConstraint: [NSLayoutConstraint]!
    @IBOutlet private var heightSubscribeButtonConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private var infoImageViews: [UIImageView]!
    
    //MARK: - Properties
    private var typeScreen: ВTypPwlScreen
    private var scaleYearlyButton = true
    private var isLoading: Bool = false
    private var subscriptionItems: [ShopItem] = []
    private var openAction: GAppAnalyticActions
    
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
        AppHudService.shared.paywallShown()
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: openAction.rawValue])
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionItems.isEmpty && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    //MARK: - Functions
    private func configureUI() {
        mostPopularContainerView.backgroundColor = UIColor.appColor(.TextColor_1)
        closeButton.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.3)
        
        [containerButtonYearly, containerButtonMonthly].forEach {
            $0?.backgroundColor = ThemeService.shared.activeColor
        }
        
        infoImageViews.forEach { $0.tintColor = ThemeService.shared.activeColor }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1.0
            }
        }
        
        mostPopularLabel.layer.cornerRadius = 5
        subtitleLabelBottomConstraint.constant = min(max(.appHeight * 0.05, Defaults.minSubtitleLabelBottom), Defaults.maxSubtitleLabelBottom)
        priceDescriptionLabelTopConstraint.constant = min(max(.appHeight * 0.05, Defaults.minSubtitleLabelBottom), 40)
        verticalSpacingViewsConstraints.forEach { constraint in
            constraint.constant = min(max(.appHeight * 0.03, 10), 20)
        }
        
        verticalSpacingsLabelsConstraint.forEach { constraint in
            constraint.constant = min(max(.appHeight * 0.01, 2), 10)
        }
        
        heightSubscribeButtonConstraints.forEach { constraint in
            constraint.constant = min(max(.appHeight * 0.08, 55), 60)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.containerButtonYearly.pulseAnimation()
        }
        
        scaleButton()
        
        subTitleLabel.textColor = ThemeService.shared.activeColor
        
        let fontMultiplier: CGFloat = 0.02
        let fontSize = min(max(.appHeight * fontMultiplier, Defaults.minSizeDescriptionLabels), Defaults.maxSizeDescriptionLabels)
        
        [bostSubTitleLabel, noiseSubTitleLabel, speechSubTitleLabel].forEach { label in
            label?.font = label?.font.withSize(fontSize)
            label?.textColor = UIColor.appColor(.UnactiveButton_1)
        }
        
        [boostLabel, noiseLabel, speechLabel].forEach { label in
            label?.font = label?.font.withSize(fontSize)
        }
        
        localizedUI()
        changeFontInLabels()
    }
    
    private func localizedUI() {
        mostPopularLabel.text = "Most popular".localized()
        titleYearlyButtonLabel.text = "Yearly".localized()
        titleMonthlyButtonLabel.text = "Monthly".localized()
        titleLabel.text = "Full Access".localized()
        subTitleLabel.text = "Improve your experience".localized()
        boostLabel.text = "Super Boost".localized()
        bostSubTitleLabel.text = "Maximum sound concentration".localized()
        noiseLabel.text = "Noise Suppression".localized()
        noiseSubTitleLabel.text = "Eliminates background noise".localized()
        speechSubTitleLabel.text = "It is real time speech to text transcription and translation".localized()
        speechLabel.text = "Transcribe & Translate".localized()
        privacyButton.setTitle("Privacy Policy".localized(), for: .normal)
        termsButton.setTitle("Terms of Use".localized(), for: .normal)
        restoreButton.setTitle("Restore".localized(), for: .normal)
        redeemPromocodeButton.setTitle("Redeem code", for: .normal)
    }
    
    private func changeFontInLabels() {
        let fontMultiplier: CGFloat = 0.04
        let priceFontMultiplier: CGFloat = 0.02
        let titleFontSize = min(max(.appHeight * fontMultiplier, Defaults.minSizeFontTitleLabel), Defaults.maxSizeFontTitleLabel)
        let subTitleFontSize = min(max(.appHeight * fontMultiplier, Defaults.minSizeFontSubTitleLabel), Defaults.maxSizeFontSubTitleLabel)
        let descriptionPriceLabelFontSize = min(max(.appHeight * priceFontMultiplier, Defaults.minSizeFontDescriptionPriceLabel), Defaults.maxSizeFontDescriptionPriceLabel)
        
        titleLabel.font = titleLabel.font.withSize(titleFontSize)
        subTitleLabel.font = subTitleLabel.font.withSize(subTitleFontSize)
        descriptionPriceLabel.font = descriptionPriceLabel.font.withSize(descriptionPriceLabelFontSize)
    }
    
    private func scaleButton() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.containerButtonMonthly.transform = self.scaleYearlyButton ? CGAffineTransform(scaleX: 0.8, y: 0.8) : CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.containerButtonMonthly.alpha = self.scaleYearlyButton ? 0.5 : 1.0
            self.containerButtonYearly.alpha = self.scaleYearlyButton ? 1.0 : 0.5
            self.scaleYearlyButton ? self.containerButtonYearly.pulseAnimation() : self.containerButtonYearly.layer.removeAllAnimations()
            self.scaleYearlyButton ? self.containerButtonMonthly.layer.removeAllAnimations() : self.containerButtonMonthly.pulseAnimation()
            self.containerButtonYearly.transform = self.scaleYearlyButton ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    private func loadSubscriptionPlans() {
        hideView()
        isLoading = true
        InAppPurchasesService.shared.fetchProducts(with: .subscriptions) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.isLoading = false
            self.subscriptionItems = AppHudService.shared.experimentProducts
            DispatchQueue.main.async {
                self.configureUIAfterSubscriptionsLoading()
                self.showView()
            }
        }
    }
    
    private func showView() {
        UIView.animate(withDuration: 0.3) {[weak self] in
            switch self?.typeScreen {
            case .regular:
                self?.mostPopularContainerView.isHidden = false
                self?.yearlyButtonSubscribeBottomConstraint.constant = 15 + min(max(.appHeight * 0.08, 55), 60)
                self?.monthlySubscribeButtonHeightConstraint.constant = min(max(.appHeight * 0.08, 55), 60)
                self?.titleYearlyButtonLabel.textAlignment = NSTextAlignment.left
            case .trial:
                self?.titleYearlyButtonLabel.textAlignment = NSTextAlignment.center
            case .none:
                break
            }
        }
    }
    
    private func hideView() {
        yearlyButtonSubscribeBottomConstraint.constant = 10
        mostPopularContainerView.isHidden = true
        titleYearlyButtonLabel.textAlignment = NSTextAlignment.center
        monthlySubscribeButtonHeightConstraint.constant = 0
        titleYearlyButtonLabel.text = "Loading...".localized()
        
        if typeScreen == .regular {
            priceDescriptionLabelTopConstraint.constant = 0
        }
    }
    
    private func configureUIAfterSubscriptionsLoading() {
        switch typeScreen {
        case .regular:
            guard let yearlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.annualSubscriptionId }),
                  let monthlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.monthlySubscriptionId }) else {
                return
            }
            
            let monthlyPriceForYearlyPlan = ((yearlySubscriptionPlan.skProduct?.price.doubleValue ?? 1.0) / 12.0).rounded(toPlaces: 2)
            
            titleYearlyButtonLabel.text = "Yearly".localized()
            titleMonthlyButtonLabel.text = "Monthly".localized()
            descriptionPriceLabel.text = ""
            priceMonthlyButtonLabel.text = monthlySubscriptionPlan.skProduct?.regularPrice
            priceYearlyButtonLabel.text = yearlySubscriptionPlan.skProduct?.regularPrice ?? ""
            descriptionYearlyButtonLabel.attributedText = NSMutableAttributedString(string: "Only %@ per %@".localized(with: ["\(yearlySubscriptionPlan.skProduct?.regularPrice(for: monthlyPriceForYearlyPlan) ?? "")", "month".localized()]), attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        case .trial:
            guard let monthlySubscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.monthlySubscriptionId }) else {
                return
            }
            
            titleYearlyButtonLabel.text = "Try Free & Subscribe".localized()
            let monthlyPrice = "\(monthlySubscriptionPlan.skProduct?.regularPrice ?? "")/\(monthlySubscriptionPlan.skProduct?.duration(for: .regular).components(separatedBy: " ").last ?? "")"
            let descriptionText = "First %@ free. After %@".localized(with: [monthlySubscriptionPlan.skProduct?.duration(for: .trial) ?? "", monthlyPrice])
            descriptionPriceLabel.text = descriptionText
            subTitleLabel.text = "Try $@ Free".localized(with: [monthlySubscriptionPlan.skProduct?.duration(for: .trial) ?? ""])
        }
    }
    
    private func purchase(plan: ShopItem) {
        HAppLoaderView.showLoader(at: self.view, animated: true)
        InAppPurchasesService.shared.purchase(plan, from: .subscriptions) { [weak self] isSuccess in
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
        AppHudService.shared.paywallClosed()
        dismiss(animated: true)
    }
    
    //MARK: - @IBAction
    @IBAction private func monthlySubscribeButtonAction(_ sender: UIButton) {
        guard let subscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.monthlySubscriptionId }) else {
            return
        }
        TapticEngine.impact.feedback(.heavy)
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.purchase.rawValue)_\(subscriptionPlan.productId)"])
        scaleYearlyButton = false
        scaleButton()
        purchase(plan: subscriptionPlan)
    }
    
    @IBAction private func yearlySubscribeButtonAction(_ sender: UIButton) {
        if !subscriptionItems.isEmpty {
            switch typeScreen {
            case .trial:
                guard let subscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.monthlySubscriptionId }) else {
                    return
                }
                purchase(plan: subscriptionPlan)
                AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.purchase.rawValue)_\(subscriptionPlan.productId)"])
            case .regular:
                guard let subscriptionPlan = subscriptionItems.first(where: { $0.productId == CAppConstants.Keys.annualSubscriptionId }) else {
                    return
                }
                purchase(plan: subscriptionPlan)
                AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.purchase.rawValue)_\(subscriptionPlan.productId)"])
            }
            TapticEngine.impact.feedback(.heavy)
            scaleYearlyButton = true
            scaleButton()
        } else if !isLoading {
            TapticEngine.impact.feedback(.medium)
            loadSubscriptionPlans()
        }
    }
    
    @IBAction private func restoreButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.restore.rawValue])
        HAppLoaderView.showLoader(at: view, animated: true)
        InAppPurchasesService.shared.restorePurchases { [weak self] isSuccess in
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
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.privacy.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
    }
    
    @IBAction private func termsButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.terms.rawValue])
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
    }
    
    @IBAction private func closeButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        typeScreen == .trial ? AppsNavManager.shared.presentCatchUpAfter(60.0) : Void()
        closePaywall()
    }
    
    @IBAction private func redeemPromocodeAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2Paywall, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.redeem.rawValue])
        InAppPurchasesService.shared.presentRedeemScreen()
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
