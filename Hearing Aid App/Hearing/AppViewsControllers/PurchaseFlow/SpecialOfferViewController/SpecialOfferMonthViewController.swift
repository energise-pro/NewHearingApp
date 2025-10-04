import UIKit

class SpecialOfferMonthViewController: SpecialOfferBaseViewController { // pw_special_monthly
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
    
    private let bottomViewDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.appColor(.Grey100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let continueButton = UIButton()
        continueButton.backgroundColor = UIColor.appColor(.Red100)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        continueButton.setTitle("Get 50% OFF", for: .normal)
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
        view.addSubview(bottomViewDescriptionLabel)
        view.addSubview(bottomButtomStackView)
        
        NSLayoutConstraint.activate([
            // ContinueButton
            continueButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            continueButton.heightAnchor.constraint(equalToConstant: 57),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26), // if not need pulse - constant: 16
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            
            // BottomViewDescriptionLabel
            bottomViewDescriptionLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 16),
            bottomViewDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomViewDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // BottomButtomStackView
            bottomButtomStackView.topAnchor.constraint(equalTo: bottomViewDescriptionLabel.bottomAnchor, constant: 16),
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
        imageView.image = CAppConstants.Images.specialOffer50OffTopImage
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let countdownContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countdownViewTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownMinuteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownSeparatorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownSecondsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4.0
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let countdownContainerView: ShadowBorderView = {
        let view = ShadowBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthProductPerDayView: PaywallProductPerDayView = {
        let view = PaywallProductPerDayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthProductDefaultView: PaywallProductDefaultView = {
        let view = PaywallProductDefaultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isLoading: Bool = false
    private var subscriptionItems: [ShopItem] = []
    private var openAction: GAppAnalyticActions
    private var selectedPlan: ShopItem?
    private var selectedProductView: PaywallProductBaseView?
    private var analyticProperties: [String: String] = [:]
    private var countdownTimer: Timer?
    private var isProductPerDayView = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_product_perDay_special.rawValue).boolValue
    private var titleLabelTopConstraint: NSLayoutConstraint!
    
    //MARK: - Init
    init(openAction: GAppAnalyticActions) {
        self.openAction = openAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        EApphudServiceAp.shared.paywallShown()
        configureUI()
        configureCountdownTimer()
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
        
        titleLabel.text = "🔥 Don't Miss Out 🔥".localized()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.23
        subtitleLabel.attributedText = NSMutableAttributedString(
            string: "Get Premium for a full week with a limited-time 50% discount!".localized(),
            attributes:[
                .kern: -0.31,
                .paragraphStyle: paragraphStyle
            ]
        )
        subtitleLabel.textAlignment = .center
        countdownViewTitle.text = "Your offer expires in".localized()
        
        addSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(topImageView)
        contentView.addSubview(countdownContentView)
        countdownContentView.addSubview(countdownViewTitle)
        countdownStackView.addArrangedSubview(countdownMinuteLabel)
        countdownStackView.addArrangedSubview(countdownSeparatorLabel)
        countdownStackView.addArrangedSubview(countdownSecondsLabel)
        countdownContentView.addSubview(countdownStackView)
        contentView.addSubview(countdownContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        if isProductPerDayView {
            contentView.addSubview(monthProductPerDayView)
        } else {
            contentView.addSubview(monthProductDefaultView)
        }
        view.addSubview(bottomView)
        view.addSubview(restoreButton)
        
        activateLayoutConstraint()
        updateTitleSpacing()
    }
    
    private func activateLayoutConstraint() {
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: countdownContainerView.bottomAnchor, constant: calculateDynamicSpacing())
        titleLabelTopConstraint.isActive = true
        
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
            
            // TopImageView
            topImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topImageView.heightAnchor.constraint(equalToConstant: 372),
            topImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // CountdownContentView
            countdownContentView.heightAnchor.constraint(equalToConstant: 85),
            countdownContentView.widthAnchor.constraint(equalToConstant: 187),
            countdownContentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countdownContentView.topAnchor.constraint(equalTo: topImageView.topAnchor, constant: 280),
            
            // CountdownViewTitle
            countdownViewTitle.heightAnchor.constraint(equalToConstant: 25),
            countdownViewTitle.topAnchor.constraint(equalTo: countdownContentView.topAnchor, constant: 12),
            countdownViewTitle.leadingAnchor.constraint(equalTo: countdownContentView.leadingAnchor, constant: 16),
            countdownViewTitle.trailingAnchor.constraint(equalTo: countdownContentView.trailingAnchor, constant: -16),
            
            // CountdownStackView
            countdownStackView.heightAnchor.constraint(equalToConstant: 36),
            countdownStackView.topAnchor.constraint(equalTo: countdownViewTitle.bottomAnchor),
            countdownStackView.centerXAnchor.constraint(equalTo: countdownContentView.centerXAnchor),
            
            // CountdownContainerView
            countdownContainerView.topAnchor.constraint(equalTo: countdownContentView.topAnchor),
            countdownContainerView.leadingAnchor.constraint(equalTo: countdownContentView.leadingAnchor),
            countdownContainerView.bottomAnchor.constraint(equalTo: countdownContentView.bottomAnchor),
            countdownContainerView.trailingAnchor.constraint(equalTo: countdownContentView.trailingAnchor),
            
            // TitleLabel
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            // SubtitleLabel
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // BottomView
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: AppsNavManager.shared.safeAreaInset.bottom + 170),
        ])
        
        if isProductPerDayView {
            NSLayoutConstraint.activate([
                // MonthProductView
                monthProductPerDayView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
                monthProductPerDayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                monthProductPerDayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                monthProductPerDayView.heightAnchor.constraint(equalToConstant: 70),
                monthProductPerDayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        } else {
            NSLayoutConstraint.activate([
                // MonthProductDefaultView
                monthProductDefaultView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
                monthProductDefaultView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                monthProductDefaultView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                monthProductDefaultView.heightAnchor.constraint(equalToConstant: 70),
                monthProductDefaultView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        }
    }
    
    private func calculateDynamicSpacing() -> CGFloat {
        let remainingSpace = scrollView.frame.height - contentView.frame.height
        let minSpacing: CGFloat = 28
        let additionalSpacing = max(0, remainingSpace)
        return minSpacing + additionalSpacing
    }
    
    private func updateTitleSpacing() {
        titleLabelTopConstraint.constant = calculateDynamicSpacing()
    }
    
    private func loadSubscriptionPlans() {
        let placementIdentifier = KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Price_HA_PT_5_pw_special_monthly.rawValue).stringValue ?? "plc"
        //let placementIdentifier = "plc"
        TInAppService.shared.fetchProducts(with: placementIdentifier) { [weak self] items in
            guard let self = self, let items = items, !items.isEmpty else { return }
            self.subscriptionItems = items
            DispatchQueue.main.async {
                self.configureUIAfterSubscriptionsLoading()
            }
        }
        
        analyticProperties[GAppAnalyticActions.source.rawValue] = openAction.rawValue
        analyticProperties["pwl_version"] = "pw_special_monthly"
        analyticProperties["offer"] = placementIdentifier
        KAppConfigServic.shared.analytics.track(.paywallSeen, with: analyticProperties)
    }
    
    private func configureUIAfterSubscriptionsLoading() {
        guard let monthSubscriptionPlan = subscriptionItems.first(where: {$0.skProduct?.introductoryPrice != nil}) else {
            return
        }
        
        if isProductPerDayView {
            monthProductPerDayView.product = monthSubscriptionPlan
            monthProductPerDayView.isSelected = true
            configureProductPerDayView(monthProductPerDayView, withProduct: monthSubscriptionPlan)
            
            selectedProductView = monthProductPerDayView
        } else {
            monthProductDefaultView.product = monthSubscriptionPlan
            monthProductDefaultView.isSelected = true
            configureProductDefaultView(monthProductDefaultView, withProduct: monthSubscriptionPlan)
            
            selectedProductView = monthProductDefaultView
        }
        
        selectedPlan = monthSubscriptionPlan
        updateTitleSpacing()
    }
    
    private func configureProductPerDayView(_ view: PaywallProductPerDayView, withProduct product: ShopItem) {
        view.perDayLabel.text = "per day".localized()
        view.dollarLabel.text = "$"
        view.dollarPricePerDayLabel.text = "0"
        view.centPricePerDayLabel.text = "00"
        view.pricePerPeriodLabel.text = "$0.00"
        
        if let skProduct = product.skProduct {
            if let subscriptionPeriod = skProduct.subscriptionPeriod {
                let localizedSubscriptionPeriod = subscriptionPeriod.localizedPeriod()
                view.durationLabel.text = localizedSubscriptionPeriod
            } else {
                let localizedDescription = skProduct.localizedDescription
                view.durationLabel.text = localizedDescription
            }
            
            var dayPrice = skProduct.price.doubleValue / 7.0
            if let introductoryPrice = skProduct.introductoryPrice {
                dayPrice = (skProduct.introductoryPrice?.price.doubleValue ?? 0) / 7.0
                
                let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale) ?? ""
                let localizedIntroductoryPrice = introductoryPrice.price.localizedPrice(for: skProduct.priceLocale) ?? ""
            
                bottomViewDescriptionLabel.text = "%@ for the first week, then %@ per week. Cancel anytime.".localized(with: [localizedIntroductoryPrice, localizedPrice])
                
                let attributedPricePerPeriod = NSMutableAttributedString(string: localizedPrice, attributes: [
                    .foregroundColor: UIColor.appColor(.Grey100)!,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.appColor(.Red100)!
                ])
                attributedPricePerPeriod.append(NSAttributedString(string: " "))
                attributedPricePerPeriod.append(NSAttributedString(string: localizedIntroductoryPrice))
                view.pricePerPeriodLabel.attributedText = attributedPricePerPeriod
            } else {
                let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale)
                view.pricePerPeriodLabel.text = localizedPrice
            }
            
            let dayPriceDollars = Int(dayPrice)
            let dayPriceCents = dayPrice.truncatingRemainder(dividingBy: 1) * 100
            
            view.dollarPricePerDayLabel.text = "\(dayPriceDollars)"
            view.centPricePerDayLabel.text = String(format: "%i", Int(dayPriceCents))
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
            
            if let introductoryPrice = skProduct.introductoryPrice {
                let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale) ?? ""
                let localizedIntroductoryPrice = introductoryPrice.price.localizedPrice(for: skProduct.priceLocale) ?? ""
            
                bottomViewDescriptionLabel.text = "%@ for the first week, then %@ per month. Cancel anytime.".localized(with: [localizedIntroductoryPrice, localizedPrice])
                
                view.priceLabel.attributedText = NSAttributedString(string: localizedIntroductoryPrice, attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                    .foregroundColor: UIColor.appColor(.White100)!
                ])
                view.showPerPeriodLabel = true
                view.pricePerPeriodLabel.attributedText = NSAttributedString(string: localizedPrice, attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: UIColor.appColor(.Grey100)!,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.appColor(.Red100)!
                ])
            }
        }
    }
    
    private func configureCountdownTimer() {
        let expirationDate = currentExpirationDate()
        if expirationDate?.timeIntervalSinceNow ?? 0 <= 0 {
            let newExpirationDate = Date().addingTimeInterval(600) // 10 minutes - 60 * 10
            UserDefaultsStorage.shared.specialOfferExpirationDate = newExpirationDate
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SpecialOfferTimerUpdatedNotification, object: nil)
            }
        }
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCountdownTimer()
        }
        if let timer = countdownTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
        updateCountdownLabel()
    }
    
    private func currentExpirationDate() -> Date? {
        return UserDefaultsStorage.shared.specialOfferExpirationDate
    }
    
    @objc private func updateCountdownTimer() {
        if secondsRemaining(for: currentExpirationDate()) > 0 {
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: SpecialOfferTimerExpirationNotification, object: nil)
        }
    }
    
    private func secondsRemaining(for expirationDate: Date?) -> Int {
        guard let expirationDate = expirationDate else { return 0 }
        let remaining = Int(expirationDate.timeIntervalSinceNow)
        return max(0, remaining)
    }
    
    private func updateCountdownLabel() {
        let remainingTime = secondsRemaining(for: currentExpirationDate())
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        
        countdownMinuteLabel.text = String(format: "%02d", minutes)
        countdownSeparatorLabel.text = ":"
        countdownSecondsLabel.text = String(format: "%02d", seconds)
    }
    
    // MARK: - Layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        bottomView.addGradient([
            UIColor(red: 0.043, green: 0.011, blue: 0.175, alpha: 1),
            UIColor(red: 0.023, green: 0, blue: 0.101, alpha: 1)
        ], isHorizontal: false)
    }
    
    // MARK: - Action
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
