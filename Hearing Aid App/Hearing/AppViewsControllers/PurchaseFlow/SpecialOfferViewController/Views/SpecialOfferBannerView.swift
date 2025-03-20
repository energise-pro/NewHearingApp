import UIKit

let SpecialOfferTimerUpdatedNotification = Notification.Name.init("SpecialOfferTimerUpdatedNotification")
let SpecialOfferTimerExpirationNotification = Notification.Name.init("SpecialOfferTimerExpirationNotification")

final class SpecialOfferBannerView: UIView {
    // MARK: - Private properties
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = CAppConstants.Images.specialOfferBannerBackgroundImage
        return imageView
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = CAppConstants.Images.specialOfferCrownImage
        return imageView
    }()
    
    private let leftTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Get Premium".localized()
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    private let discountContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.Red100)
        view.layer.cornerRadius = 17
        return view
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "50% OFF".localized()
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    private let countdownContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.Red100)
        view.layer.cornerRadius = 17
        return view
    }()
    
    private let countdownMinuteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        return label
    }()
    
    private let countdownSeparatorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        return label
    }()
    
    private let countdownSecondsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.appColor(.White100)
        label.textAlignment = .center
        return label
    }()
    
    private let countdownStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 1.0
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private var countdownTimer: Timer?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private methods
    private func setupView() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 21
        self.layer.masksToBounds = true
        
        addSubview(contentView)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(leftImageView)
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(discountContentView)
        discountContentView.addSubview(discountLabel)
        contentView.addSubview(countdownContentView)
        countdownStackView.addArrangedSubview(countdownMinuteLabel)
        countdownStackView.addArrangedSubview(countdownSeparatorLabel)
        countdownStackView.addArrangedSubview(countdownSecondsLabel)
        countdownContentView.addSubview(countdownStackView)
        
        setupConstraints()
        configureObserver()
        configureCountdownTimer()
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(specialOfferTimerUpdated(notification:)), name: SpecialOfferTimerUpdatedNotification, object: nil)
    }
    
    @objc private func specialOfferTimerUpdated(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            self?.configureCountdownTimer()
        }
    }
    
    private func currentExpirationDate() -> Date? {
        return UserDefaultsStorage.shared.specialOfferExpirationDate
    }
    
    private func configureCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdownTimer), userInfo: nil, repeats: true)
        if let timer = countdownTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
        updateCountdownLabel()
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
    
    //MARK: - Layout
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        discountContentView.translatesAutoresizingMaskIntoConstraints = false
        discountLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownContentView.translatesAutoresizingMaskIntoConstraints = false
        countdownMinuteLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownSeparatorLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownSecondsLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ContentView
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // BackgroundImageView
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // LeftImageView
            leftImageView.heightAnchor.constraint(equalToConstant: 20),
            leftImageView.widthAnchor.constraint(equalTo: leftImageView.heightAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // LeftTitleLabel
            leftTitleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 6),
            leftTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // CountdownContentView
            countdownContentView.widthAnchor.constraint(equalToConstant: 78),
            countdownContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            countdownContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            countdownContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // CountdownMinuteLabel
            countdownMinuteLabel.widthAnchor.constraint(equalToConstant: 23),
            
            // CountdownSeparatorLabel
            countdownSeparatorLabel.widthAnchor.constraint(equalToConstant: 6),
            
            // CountdownSecondsLabel
            countdownSecondsLabel.widthAnchor.constraint(equalToConstant: 23),
            
            // CountdownStackView
            countdownStackView.heightAnchor.constraint(equalToConstant: 25),
            countdownStackView.widthAnchor.constraint(equalToConstant: 54),
            countdownStackView.centerYAnchor.constraint(equalTo: countdownContentView.centerYAnchor),
            countdownStackView.centerXAnchor.constraint(equalTo: countdownContentView.centerXAnchor),
            
            // DiscountContentView
            discountContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            discountContentView.trailingAnchor.constraint(equalTo: countdownContentView.leadingAnchor, constant: -4),
            discountContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // DiscountLabel
            discountLabel.topAnchor.constraint(equalTo: discountContentView.topAnchor, constant: 4),
            discountLabel.leadingAnchor.constraint(equalTo: discountContentView.leadingAnchor, constant: 12),
            discountLabel.trailingAnchor.constraint(equalTo: discountContentView.trailingAnchor, constant: -12),
            discountLabel.bottomAnchor.constraint(equalTo: discountContentView.bottomAnchor, constant: -4),
        ])
    }
}
