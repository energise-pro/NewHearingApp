import UIKit

class PaywallYearMonthViewController: UIViewController { // pw_inapp_monthly
    // MARK: - Private properties
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = CAppConstants.Images.paywallBackgroundImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let restoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = CAppConstants.Images.paywallCrownSmallImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.appColor(.White100)
        titleLabel.textAlignment = .center
        titleLabel.text = "Get Unlimited Access".localized()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // ImageView
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 36),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // TitleLabel
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return view
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let continueButton = UIButton()
        continueButton.backgroundColor = UIColor.appColor(.Red100)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        continueButton.setTitle("Continue".localized(), for: .normal)
        continueButton.setTitleColor(UIColor.appColor(.White100), for: .normal)
        continueButton.addTarget(self, action: #selector(purchaseButtonAction), for: .touchUpInside)
        continueButton.layer.cornerRadius = 28
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomButtomStackView = UIStackView()
        bottomButtomStackView.spacing = 7.0
        bottomButtomStackView.axis = .horizontal
        bottomButtomStackView.alignment = .fill
        bottomButtomStackView.distribution = .fill
        bottomButtomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let termsButton = UIButton()
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        termsButton.setTitle("Terms of use".localized(), for: .normal)
        termsButton.setTitleColor(UIColor.appColor(.Grey100), for: .normal)
        termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let dotImageView1 = UIImageView()
        dotImageView1.image = CAppConstants.Images.paywallDotImage
        dotImageView1.contentMode = .scaleAspectFit
        dotImageView1.translatesAutoresizingMaskIntoConstraints = false
        
        let privacyButton = UIButton()
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        privacyButton.setTitle("Privacy Policy".localized(), for: .normal)
        privacyButton.setTitleColor(UIColor.appColor(.Grey100), for: .normal)
        privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        
        let dotImageView2 = UIImageView()
        dotImageView2.image = CAppConstants.Images.paywallDotImage
        dotImageView2.contentMode = .scaleAspectFit
        dotImageView2.translatesAutoresizingMaskIntoConstraints = false
        
        let proceedWithBasicButton = UIButton()
        proceedWithBasicButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        let proceedWithBasicAttributedTitle = NSAttributedString(string: "Proceed with Basic".localized(), attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        proceedWithBasicButton.setAttributedTitle(proceedWithBasicAttributedTitle, for: .normal)
        proceedWithBasicButton.setTitleColor(UIColor.appColor(.Grey100), for: .normal)
        proceedWithBasicButton.addTarget(self, action: #selector(proceedWithBasicButtonTapped), for: .touchUpInside)
        proceedWithBasicButton.translatesAutoresizingMaskIntoConstraints = false
        
        bottomButtomStackView.addArrangedSubview(termsButton)
        bottomButtomStackView.addArrangedSubview(dotImageView1)
        bottomButtomStackView.addArrangedSubview(privacyButton)
        bottomButtomStackView.addArrangedSubview(dotImageView2)
        bottomButtomStackView.addArrangedSubview(proceedWithBasicButton)
        
        view.addSubview(continueButton)
        view.addSubview(bottomButtomStackView)
        
        NSLayoutConstraint.activate([
            // ContinueButton
            continueButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            continueButton.heightAnchor.constraint(equalToConstant: 57),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26), // if not need pulse - constant: 16
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            
            // BottomButtomStackView
            bottomButtomStackView.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            bottomButtomStackView.heightAnchor.constraint(equalToConstant: 18),
            bottomButtomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            continueButton.startPulseAnimationButton()
        }
        
        return view
    }()
    
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = CAppConstants.Images.paywallTopImage
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let paywallCarouselView: PaywallCarouselView = {
        let carouselView = PaywallCarouselView()
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        return carouselView
    }()
    
    private let yearProductPerDayView: PaywallProductPerDayView = {
        let view = PaywallProductPerDayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthProductPerDayView: PaywallProductPerDayView = {
        let view = PaywallProductPerDayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let yearProductDefaultView: PaywallProductDefaultView = {
        let view = PaywallProductDefaultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthProductDefaultView: PaywallProductDefaultView = {
        let view = PaywallProductDefaultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewsView: PaywallReviewsView = {
        let view = PaywallReviewsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var typeScreen: ВTypPwlScreen
    private var scaleYearlyButton = true
    private var isLoading: Bool = false
    private var subscriptionItems: [ShopItem] = []
    private var openAction: GAppAnalyticActions
    private var selectedPlan: ShopItem?
    private var selectedProductView: PaywallProductBaseView?
    private var analyticProperties: [String: String] = [:]
    
    @InAppStorage(key: "isFirstInAppShowedSpecialOffer", defaultValue: false)
    var isFirstInAppShowedSpecialOffer: Bool
    
    //MARK: - Init
    init(typeScreen: ВTypPwlScreen, openAction: GAppAnalyticActions) {
        self.typeScreen = typeScreen
        self.openAction = openAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
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
        restoreButton.setTitle("Restore".localized(), for: .normal)
        restoreButton.setTitleColor(UIColor.appColor(.Grey100), for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        
        addSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(topImageView)
        contentView.addSubview(paywallCarouselView)
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        if isProductPerDayView {
            contentView.addSubview(yearProductPerDayView)
            contentView.addSubview(monthProductPerDayView)
        } else {
            contentView.addSubview(yearProductDefaultView)
            contentView.addSubview(monthProductDefaultView)
        }
        contentView.addSubview(reviewsView)
        view.addSubview(bottomView)
        view.addSubview(restoreButton)
        
        activateLayoutConstraint()
    }
    
    private func activateLayoutConstraint() {
        NSLayoutConstraint.activate([
            // BackgroundImageView
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // RestoreButton
            restoreButton.topAnchor.constraint(equalTo: view.topAnchor, constant: AppsNavManager.shared.safeAreaInset.top + 20),
            restoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            restoreButton.heightAnchor.constraint(equalToConstant: 18),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
        
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // HeaderView
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppsNavManager.shared.safeAreaInset.top + 13),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // TopImageView
            topImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppsNavManager.shared.safeAreaInset.top),
            topImageView.heightAnchor.constraint(equalToConstant: 436),
            topImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // PaywallCarouselView
            paywallCarouselView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 95),
            paywallCarouselView.heightAnchor.constraint(equalToConstant: 210),
            paywallCarouselView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            paywallCarouselView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // BottomView
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: AppsNavManager.shared.safeAreaInset.bottom + 130),
        ])
        
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        if isProductPerDayView {
            NSLayoutConstraint.activate([
                // YearProductPerDayView
                yearProductPerDayView.topAnchor.constraint(equalTo: paywallCarouselView.bottomAnchor, constant: 20),
                yearProductPerDayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                yearProductPerDayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                yearProductPerDayView.heightAnchor.constraint(equalToConstant: 70),
                
                // MonthProductView
                monthProductPerDayView.topAnchor.constraint(equalTo: yearProductPerDayView.bottomAnchor, constant: 12),
                monthProductPerDayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                monthProductPerDayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                monthProductPerDayView.heightAnchor.constraint(equalToConstant: 70),
                
                // ReviewsView
                reviewsView.topAnchor.constraint(equalTo: monthProductPerDayView.bottomAnchor, constant: 20),
                reviewsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                reviewsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                reviewsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        } else {
            NSLayoutConstraint.activate([
                // YearProductDefaultView
                yearProductDefaultView.topAnchor.constraint(equalTo: paywallCarouselView.bottomAnchor, constant: 20),
                yearProductDefaultView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                yearProductDefaultView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                yearProductDefaultView.heightAnchor.constraint(equalToConstant: 70),
                
                // MonthProductDefaultView
                monthProductDefaultView.topAnchor.constraint(equalTo: yearProductDefaultView.bottomAnchor, constant: 12),
                monthProductDefaultView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                monthProductDefaultView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                monthProductDefaultView.heightAnchor.constraint(equalToConstant: 70),
                
                // ReviewsView
                reviewsView.topAnchor.constraint(equalTo: monthProductDefaultView.bottomAnchor, constant: 20),
                reviewsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                reviewsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                reviewsView.heightAnchor.constraint(equalToConstant: 146),
                reviewsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        }
    }
    
    private func loadSubscriptionPlans() {
        let placementIdentifier = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Price_HA_PT_5_pw_inapp_monthly.rawValue).stringValue ?? "plc"
        TInAppService.shared.fetchProducts(with: placementIdentifier) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.subscriptionItems = items
            DispatchQueue.main.async {
                self.configureUIAfterSubscriptionsLoading()
            }
        }
        
        analyticProperties[GAppAnalyticActions.source.rawValue] = openAction.rawValue
        analyticProperties["pwl_version"] = "pw_inapp_monthly"
        analyticProperties["offer"] = placementIdentifier
        KAppConfigServic.shared.analytics.track(.paywallSeen, with: analyticProperties)
    }
    
    private func configureUIAfterSubscriptionsLoading() {
        guard let yearlySubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "year"}),
              let monthSubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "month"}) else {
            return
        }
        
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        if isProductPerDayView {
            var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onYearProductViewTap(_:)))
            yearProductPerDayView.addGestureRecognizer(tapGesture)
            yearProductPerDayView.product = yearlySubscriptionPlan
            yearProductPerDayView.isSelected = true
            yearProductPerDayView.showSavePercentView = true
            let savingsPercentage = calculateSavingsPercentage(monthlyProduct: monthSubscriptionPlan, yearlyProduct: yearlySubscriptionPlan)
            yearProductPerDayView.savePercentLabel.text = "🔥 " + "Save".localized() + " \(String(format: "%i", savingsPercentage))%"
            configureProductPerDayView(yearProductPerDayView, withProduct: yearlySubscriptionPlan)
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMonthProductViewTap(_:)))
            monthProductPerDayView.addGestureRecognizer(tapGesture)
            monthProductPerDayView.product = monthSubscriptionPlan
            monthProductPerDayView.isSelected = false
            configureProductPerDayView(monthProductPerDayView, withProduct: monthSubscriptionPlan)
            
            selectedProductView = yearProductPerDayView
        } else {
            var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onYearProductViewTap(_:)))
            yearProductDefaultView.addGestureRecognizer(tapGesture)
            yearProductDefaultView.product = yearlySubscriptionPlan
            yearProductDefaultView.isSelected = true
            yearProductDefaultView.showMostPopularView = true
            yearProductDefaultView.mostPopularLabel.text = "Most Popular".localized()
            if let skProduct = yearlySubscriptionPlan.skProduct {
                let perMonthPrice = (skProduct.price.doubleValue / 12.0).rounded(toPlaces: 2)
                let localizedPerMonthPrice = skProduct.regularPrice(for: perMonthPrice)
                yearProductDefaultView.showPerPeriodLabel = true
                yearProductDefaultView.pricePerPeriodLabel.text = "only".localized() + " " + "\(localizedPerMonthPrice)" + " " + "per month".localized()
            }
            configureProductDefaultView(yearProductDefaultView, withProduct: yearlySubscriptionPlan)
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMonthProductViewTap(_:)))
            monthProductDefaultView.addGestureRecognizer(tapGesture)
            monthProductDefaultView.product = monthSubscriptionPlan
            monthProductDefaultView.isSelected = false
            configureProductDefaultView(monthProductDefaultView, withProduct: monthSubscriptionPlan)
            
            selectedProductView = yearProductDefaultView
        }
        
        selectedPlan = yearlySubscriptionPlan
    }
    
    private func configureProductPerDayView(_ view: PaywallProductPerDayView, withProduct product: ShopItem) {
        view.perDayLabel.text = "per day".localized()
        view.dollarLabel.text = "$"
        view.dollarPricePerDayLabel.text = "0"
        view.centPricePerDayLabel.text = "00"
        view.pricePerPeriodLabel.text = "$0.00"
        
        if let skProduct = product.skProduct {
            if let subscriptionPeriod = skProduct.subscriptionPeriod {
                let price = skProduct.price.doubleValue
                let localizedSubscriptionPeriod = subscriptionPeriod.localizedPeriod()
                view.durationLabel.text = localizedSubscriptionPeriod
                
                let dayPrice = subscriptionPeriod.unit == .year ? price / 365.0 : price / 30.0
                let dayPriceDollars = Int(dayPrice)
                let dayPriceCents = dayPrice.truncatingRemainder(dividingBy: 1) * 100
                
                view.dollarPricePerDayLabel.text = "\(dayPriceDollars)"
                view.centPricePerDayLabel.text = String(format: "%i", Int(dayPriceCents))
            } else {
                let localizedDescription = skProduct.localizedDescription
                view.durationLabel.text = localizedDescription
            }
            
            let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale)
            view.pricePerPeriodLabel.text = localizedPrice
        }
    }
    
    private func configureProductDefaultView(_ view: PaywallProductDefaultView, withProduct product: ShopItem) {
        if let skProduct = product.skProduct {
            if let subscriptionPeriod = skProduct.subscriptionPeriod {
                let localizedSubscriptionPeriod = subscriptionPeriod.localizedPeriod()
                view.durationLabel.text = localizedSubscriptionPeriod
            } else {
                let localizedDescription = skProduct.localizedDescription
                view.durationLabel.text = localizedDescription
            }
            
            let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale)
            view.priceLabel.text = localizedPrice
        }
    }
    
    private func updateProductViews() {
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        if isProductPerDayView {
            let isYearProductSelected = selectedProductView == yearProductPerDayView
            yearProductPerDayView.isSelected = isYearProductSelected
            monthProductPerDayView.isSelected = !isYearProductSelected
        } else {
            let isYearProductSelected = selectedProductView == yearProductDefaultView
            yearProductDefaultView.isSelected = isYearProductSelected
            monthProductDefaultView.isSelected = !isYearProductSelected
        }
    }
    
    // MARK: - Layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
        bottomView.addGradient([
            UIColor(red: 0.043, green: 0.011, blue: 0.175, alpha: 1),
            UIColor(red: 0.023, green: 0, blue: 0.101, alpha: 1)
        ], isHorizontal: false)
    }
    
    // MARK: - Action
    @objc func onYearProductViewTap(_: UIGestureRecognizer) {
        guard let subscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "year"}) else { return }
        
        selectedPlan = subscriptionPlan
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        selectedProductView = isProductPerDayView ? yearProductPerDayView : yearProductDefaultView
        updateProductViews()
    }
    
    @objc func onMonthProductViewTap(_: UIGestureRecognizer) {
        guard let subscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.regulatDuration == "month"}) else { return }
        
        selectedPlan = subscriptionPlan
        let isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_inapp.rawValue).boolValue
        selectedProductView = isProductPerDayView ? monthProductPerDayView : monthProductDefaultView
        updateProductViews()
    }
        
    @objc func termsButtonTapped() {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
    }
    
    @objc func privacyButtonTapped() {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
    }
    
    @objc func purchaseButtonAction(_ sender: UIButton) {
        guard let selectedPlan = selectedPlan else {
            return
        }
        TapticEngine.impact.feedback(.heavy)
        purchase(plan: selectedPlan)
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
    
    @objc func proceedWithBasicButtonTapped() {
        closePaywall()
    }
    
    @objc func restoreButtonTapped() {
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
    
    private func closePaywall() {
        TapticEngine.impact.feedback(.heavy)
        KAppConfigServic.shared.analytics.track(.paywallPassed, with: analyticProperties)
        if openAction != .openAfterOnboarding && !isFirstInAppShowedSpecialOffer {
            isFirstInAppShowedSpecialOffer = true
            AppsNavManager.shared.presentSpecialOffer(1.0, with: openAction)
        }
        EApphudServiceAp.shared.paywallClosed()
        dismiss(animated: true)
    }
    
    func calculateSavingsPercentage(monthlyProduct: ShopItem, yearlyProduct: ShopItem) -> Int {
        if let monthlyPrice = monthlyProduct.skProduct?.price.doubleValue, let yearlyPrice = yearlyProduct.skProduct?.price.doubleValue {
            let totalMonthlyCost = monthlyPrice * 12
            return Int(((totalMonthlyCost - yearlyPrice) / totalMonthlyCost) * 100)
        }
        return 0
    }
}
