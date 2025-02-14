//
//  SpecialOfferViewController.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 13.12.2024.
//

import UIKit

class SpecialOfferViewController: UIViewController {
    
    //MARK: - @IBoutlets
    @IBOutlet private weak var purchaseContainerView: UIView!
    @IBOutlet private weak var purchaseButtonLabel: UILabel!
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

    @IBOutlet weak var headerViewTopLabel: UILabel!
    @IBOutlet weak var headerViewBottomLabel: UILabel!
    @IBOutlet weak var countdownContainerView: ShadowBorderView!
    @IBOutlet weak var countdownContentView: UIView!
    @IBOutlet weak var countdownViewTitle: UILabel!
    @IBOutlet weak var countdownMinuteLabel: UILabel!
    @IBOutlet weak var countdownSeparatorLabel: UILabel!
    @IBOutlet weak var countdownSecondsLabel: UILabel!
    
    //MARK: - Properties
    private var openAction: GAppAnalyticActions
    private var isLoading: Bool = false
    private var subscriptionItems: [ShopItem] = []
    private var selectedPlan: ShopItem?
    private var countdownTimer: Timer?
    private var expirationDate: Date?
//    private var expirationDate: Date? {
//        get {
//            if let timestamp = UserDefaults.standard.object(forKey: "specialOfferExpirationDate") as? TimeInterval {
//                return Date(timeIntervalSince1970: timestamp)
//            }
//            return nil
//        }
//        set {
//            if let newValue = newValue {
//                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "specialOfferExpirationDate")
//            } else {
//                UserDefaults.standard.removeObject(forKey: "specialOfferExpirationDate")
//            }
//        }
//    }
    
    //MARK: - Init
    init(openAction: GAppAnalyticActions) {
        self.openAction = openAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    deinit {
        countdownTimer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.setValue(true, forKey: CAppConstants.Keys.wasPresentedCatchUp)
        EApphudServiceAp.shared.paywallShown()
        configureUI()
        configureCountdownTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscriptionItems.isEmpty && !isLoading ? loadSubscriptionPlans() : Void()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
        countdownTimer = nil
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
        
        selectProductView(containerButtonYearly)
        unselectProductView(containerButtonWeekly)
        
        localizedUI()
        
        let closeButtonTimeInterval = Int(truncating: KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Xtime_HA_PT_2_pw_special_inapp_1.rawValue).numberValue)
        Timer.scheduledTimer(withTimeInterval: TimeInterval(closeButtonTimeInterval), repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1.0
            }
        }
        KAppConfigServic.shared.analytics.track(.paywallSeen, with: [
            GAppAnalyticActions.source.rawValue: openAction.rawValue,
            "pwl_version" : "pw_special_inapp_1",
            "offer" : "plc"
        ])
    }
    
    private func configureCountdownTimer() {
        expirationDate = Date().addingTimeInterval(120) // 2 minutes - 60 * 2
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdownTimer), userInfo: nil, repeats: true)
        if let timer = countdownTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
        updateCountdownLabel()
    }
    
    @objc private func updateCountdownTimer() {
        if secondsRemaining(for: expirationDate) > 0 {
            TapticEngine.impact.feedback(.light)
            updateCountdownLabel()
        } else {
            handleCountdownTimerExpiration()
        }
    }
    
    private func handleCountdownTimerExpiration() {
        updateCountdownLabel()
        countdownContainerView.isHidden = true
        countdownContentView.isHidden = true
        countdownTimer?.invalidate()
    }
    
    private func secondsRemaining(for expirationDate: Date?) -> Int {
        guard let expirationDate = expirationDate else { return 0 }
        let remaining = Int(expirationDate.timeIntervalSinceNow)
        return max(0, remaining)
    }
    
    private func updateCountdownLabel() {
        let remainingTime = secondsRemaining(for: expirationDate)
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        
        countdownMinuteLabel.text = String(format: "%d", minutes)
        countdownSeparatorLabel.text = ":"
        countdownSecondsLabel.text = String(format: "%02d", seconds)
    }
    
    private func localizedUI() {
        mostPopularLabel.text = "Most popular".localized()
//        titleYearlyButtonLabel.text = "3 Days Free".localized()
//        titleWeeklyButtonLabel.text = "1 Week".localized()
        privacyButton.setTitle("Privacy Policy".localized(), for: .normal)
        termsButton.setTitle("Terms of Use".localized(), for: .normal)
        restoreButton.setTitle("Restore".localized(), for: .normal)
    }
    
    private func loadSubscriptionPlans() {
        let placementIdentifier = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Price_HA_PT_2_pw_special_inapp_1.rawValue).stringValue ?? "plc"
        TInAppService.shared.fetchProducts(with: placementIdentifier) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.subscriptionItems = items //EApphudServiceAp.shared.experimentProducts
            DispatchQueue.main.async {
                self.configureUIAfterSubscriptionsLoading()
            }
        }
    }
    
    private func configureUIAfterSubscriptionsLoading() {
        guard let lifetimeSubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.isLifetimePurchase == true}),
              let weeklySubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "week"}) else {
            return
        }
        
        let daysFree = lifetimeSubscriptionPlan.skProduct?.duration(for: .trial)
        if let daysFree = daysFree, !daysFree.isEmpty {
            titleYearlyButtonLabel.text = daysFree + " " + "free".localized()
            priceYearlyButtonLabel.text = "Then %@/lifetime".localized(with: [lifetimeSubscriptionPlan.skProduct?.regularPrice ?? ""])
            purchaseButtonLabel.text = "Try Free & Subscribe".localized()
        } else {
            titleYearlyButtonLabel.text = "Lifetime".localized()
            priceYearlyButtonLabel.text = lifetimeSubscriptionPlan.skProduct?.regularPrice
            purchaseButtonLabel.text = "Continue".localized()
        }
        
        titleWeeklyButtonLabel.text = weeklySubscriptionPlan.skProduct?.duration(for: .regular) ?? "1 Week".localized()
        priceWeeklyButtonLabel.text = weeklySubscriptionPlan.skProduct?.regularPrice
        
        selectedPlan = lifetimeSubscriptionPlan
    }

    private func purchase(plan: ShopItem) {
        KAppConfigServic.shared.analytics.track(.purchaseCheckout, with: [
            GAppAnalyticActions.source.rawValue: openAction.rawValue,
            "pwl_version" : "pw_special_inapp_1",
            "offer" : "plc"
        ])
        HAppLoaderView.showLoader(at: self.view, animated: true)
        TInAppService.shared.purchase(plan, from: .subscriptions) { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            HAppLoaderView.hideLoader(for: self.view, animated: true)
            if isSuccess {
                KAppConfigServic.shared.analytics.track(.purchaseActivate, with: [
                    GAppAnalyticActions.source.rawValue: openAction.rawValue,
                    "pwl_version" : "pw_special_inapp_1",
                    "offer" : "plc"
                ])
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
        guard let subscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "week"}) else {
            return
        }
        selectedPlan = subscriptionPlan
        
        selectProductView(containerButtonWeekly)
        unselectProductView(containerButtonYearly)
        UIView.transition(with: purchaseButtonLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.purchaseButtonLabel.text = "Continue".localized()
        }, completion: nil)
    }
    
    @IBAction private func yearlySubscribeButtonAction(_ sender: UIButton) {
        guard let subscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.isLifetimePurchase == true}) else {
            return
        }
        selectedPlan = subscriptionPlan
        
        selectProductView(containerButtonYearly)
        unselectProductView(containerButtonWeekly)
        var purchaseButtonTitle = "Continue".localized()
        let daysFree = selectedPlan?.skProduct?.duration(for: .trial)
        if let daysFree = daysFree, !daysFree.isEmpty {
            purchaseButtonTitle = "Try Free & Subscribe".localized()
        }
        UIView.transition(with: purchaseButtonLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.purchaseButtonLabel.text = purchaseButtonTitle
        }, completion: nil)
    }
    
    @IBAction private func restoreButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
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
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
    }
    
    @IBAction private func termsButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
    }
    
    @IBAction private func closeButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        KAppConfigServic.shared.analytics.track(.paywallPassed, with: [
            GAppAnalyticActions.source.rawValue: openAction.rawValue,
            "pwl_version" : "pw_special_inapp_1",
            "offer" : "plc"
        ])
        closePaywall()
    }
    
    @IBAction private func redeemPromocodeAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        TInAppService.shared.presentRedeemScreen()
    }
}

class ShadowBorderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.layer.borderColor = UIColor(red: 45/255, green: 78/255, blue: 243/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor.appColor(.Purple50)!.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
    }
}
