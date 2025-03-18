import UIKit
import Foundation
import ApphudSDK
import StoreKit

class PaywallProductPerDayView: PaywallProductBaseView {
    //MARK: - Public property
    var product: ApphudProduct?
    
    var isSelected: Bool = false {
        didSet {
            updateProductView()
        }
    }
    
    var showSavePercentView: Bool = false {
        didSet {
            updateProductView()
        }
    }
    
    //MARK: - Private property
    private let savePercentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.Red100)
        view.isHidden = true
        return view
    }()
    
    private let perDayBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    //MARK: - Public property
    public let savePercentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public let durationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public let pricePerPeriodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.appColor(.Grey100)
        return label
    }()
    
    public var dollarLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public var perDayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public var dollarPricePerDayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public var centPricePerDayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    //MARK: - SetupView
    private func setupView() {
        backgroundColor = .clear
        
        layer.cornerRadius = 12
        layer.borderWidth = 1.0
        
        addSubview(durationLabel)
        addSubview(pricePerPeriodLabel)
        
        addSubview(perDayBackgroundImage)
        
        addSubview(dollarLabel)
        addSubview(dollarPricePerDayLabel)
        addSubview(centPricePerDayLabel)
        addSubview(perDayLabel)
        
        addSubview(savePercentView)
        savePercentView.addSubview(savePercentLabel)
        
        setupConstraints()
    }
    
    //MARK: - Localize
    private func setupProductView() {
        savePercentLabel.text = "🔥 Save 85%%";
        perDayLabel.text = "per day"
        dollarLabel.text = "$"
        dollarPricePerDayLabel.text = "0"
        centPricePerDayLabel.text = "00"
        pricePerPeriodLabel.text = "$0.00"
        
        if let skProduct = product?.skProduct {
            if let subscriptionPeriod = skProduct.subscriptionPeriod {
                let price = skProduct.price.doubleValue
                let localizedSubscriptionPeriod = subscriptionPeriod.localizedPeriod(for: Locale(identifier: "en"))
                durationLabel.text = localizedSubscriptionPeriod
                
                let dayPrice = subscriptionPeriod.unit == .year ? price / 365.0 : price / 7.0
                let dayPriceDollars = Int(dayPrice)
                let dayPriceCents = dayPrice.truncatingRemainder(dividingBy: 1) * 100
                
                dollarPricePerDayLabel.text = "\(dayPriceDollars)"
                centPricePerDayLabel.text = String(format: "%i", Int(dayPriceCents))
            } else {
                let localizedDescription = skProduct.localizedDescription
                durationLabel.text = localizedDescription
            }
            
            let localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale)
            pricePerPeriodLabel.text = localizedPrice
        }
    }
    
    private func updateProductView() {
        let labelColor = isSelected ? UIColor.appColor(.White100) : UIColor.appColor(.Grey100)
        let image = isSelected ? CAppConstants.Images.paywallPerDayBackgroundSelectedImage : CAppConstants.Images.paywallPerDayBackgroundImage
        let borderColor = isSelected ? UIColor.appColor(.Red100) : UIColor.appColor(.Red100)?.withAlphaComponent(0.3)
        
        backgroundColor = isSelected ? UIColor.appColor(.Red100)?.withAlphaComponent(0.24) : .clear
        layer.borderColor = borderColor?.cgColor
        
        savePercentView.isHidden = !showSavePercentView
        
        dollarLabel.textColor = labelColor
        dollarPricePerDayLabel.textColor = labelColor
        centPricePerDayLabel.textColor = labelColor
        perDayLabel.textColor = labelColor
        perDayBackgroundImage.image = image
    }
    
    private func setupConstraints() {
        savePercentView.translatesAutoresizingMaskIntoConstraints = false
        savePercentLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        pricePerPeriodLabel.translatesAutoresizingMaskIntoConstraints = false
        perDayBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        dollarLabel.translatesAutoresizingMaskIntoConstraints = false
        dollarPricePerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        centPricePerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        perDayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // SavePercentView
            savePercentView.topAnchor.constraint(equalTo: topAnchor),
            savePercentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 88),
            savePercentView.heightAnchor.constraint(equalToConstant: 24),
            
            // SavePercentLabel
            savePercentLabel.leadingAnchor.constraint(equalTo: savePercentView.leadingAnchor, constant: 8),
            savePercentLabel.trailingAnchor.constraint(equalTo: savePercentView.trailingAnchor, constant: -8),
            savePercentLabel.centerXAnchor.constraint(equalTo: savePercentView.centerXAnchor),
            savePercentLabel.centerYAnchor.constraint(equalTo: savePercentView.centerYAnchor),
            
            // DurationLabel
            durationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationLabel.heightAnchor.constraint(equalToConstant: 25),
            
            // PricePerPeriodLabel
            pricePerPeriodLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            pricePerPeriodLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pricePerPeriodLabel.heightAnchor.constraint(equalToConstant: 19),
            
            // PerDayBackgroundImage
            perDayBackgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            perDayBackgroundImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // DollarLabel
            dollarLabel.leadingAnchor.constraint(equalTo: perDayBackgroundImage.leadingAnchor, constant: 26),
            dollarLabel.topAnchor.constraint(equalTo: perDayBackgroundImage.topAnchor, constant: 12),
            
            // DollarPricePerDayLabel
            dollarPricePerDayLabel.leadingAnchor.constraint(equalTo: dollarLabel.trailingAnchor),
            dollarPricePerDayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // CentPricePerDayLabel
            centPricePerDayLabel.leadingAnchor.constraint(equalTo: dollarPricePerDayLabel.trailingAnchor, constant: 1),
            centPricePerDayLabel.topAnchor.constraint(equalTo: perDayBackgroundImage.topAnchor, constant: 12),
            
            // PerDayLabel
            perDayLabel.leadingAnchor.constraint(equalTo: dollarPricePerDayLabel.trailingAnchor, constant: 1),
            perDayLabel.topAnchor.constraint(equalTo: centPricePerDayLabel.bottomAnchor, constant: 1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: savePercentView.bounds,
                                byRoundingCorners: [.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        savePercentView.layer.mask = maskLayer
    }
}

extension SKProductSubscriptionPeriod {
    
    func localizedPeriod(for locale: Locale) -> String? {
        switch unit {
        case .day:
            if numberOfUnits == 7 { return locale.localizedComponents(weekOfMonth: 1) }
            return locale.localizedComponents(day: numberOfUnits)
        case .week:
            return locale.localizedComponents(weekOfMonth: numberOfUnits)
        case .month:
            return locale.localizedComponents(month: numberOfUnits)
        case .year:
            return locale.localizedComponents(year: numberOfUnits)
        @unknown default:
            return nil
        }
    }
    
}

extension Locale {
    
    func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = self

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}

extension NSDecimalNumber {
    
    func localizedPrice(for locale: Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self)
    }
}
