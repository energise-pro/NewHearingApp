import UIKit
import Foundation
import ApphudSDK
import StoreKit

class PaywallProductDefaultView: PaywallProductBaseView {
    //MARK: - Public property
    var product: ApphudProduct?
    
    var isSelected: Bool = false {
        didSet {
            updateProductView()
        }
    }
    
    var showMostPopularView: Bool = false {
        didSet {
            updateProductView()
        }
    }
    
    var showPerPeriodLabel: Bool = false {
        didSet {
            pricePerPeriodLabel.isHidden = !showPerPeriodLabel
            configPerPeriodLabel()
        }
    }
    
    //MARK: - Private property
    private let mostPopularView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.Red100)
        view.isHidden = true
        return view
    }()
    
    private var priceLabelCenterYAnchorConstraint: NSLayoutConstraint!
    private var priceLabelTopAnchorConstraint: NSLayoutConstraint!
    
    //MARK: - Public property
    public let mostPopularLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
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
    
    public let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    public let pricePerPeriodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.appColor(.White100)
        label.isHidden = true
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
        addSubview(priceLabel)
        addSubview(pricePerPeriodLabel)
        
        addSubview(mostPopularView)
        mostPopularView.addSubview(mostPopularLabel)
        
        setupConstraints()
    }
    
    private func updateProductView() {
        let labelColor = isSelected ? UIColor.appColor(.White100) : UIColor.appColor(.Grey100)
        let borderColor = isSelected ? UIColor.appColor(.Red100) : UIColor.appColor(.Red100)?.withAlphaComponent(0.3)
        
        backgroundColor = isSelected ? UIColor.appColor(.Red100)?.withAlphaComponent(0.24) : .clear
        layer.borderColor = borderColor?.cgColor
        
        priceLabel.textColor = labelColor
        pricePerPeriodLabel.textColor = labelColor
        
        mostPopularView.isHidden = !showMostPopularView
        pricePerPeriodLabel.isHidden = !showPerPeriodLabel
    }
    
    private func configPerPeriodLabel() {
        priceLabelCenterYAnchorConstraint.isActive = false
        priceLabelTopAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // PricePerPeriodLabel
            pricePerPeriodLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            pricePerPeriodLabel.heightAnchor.constraint(equalToConstant: 19),
            pricePerPeriodLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func setupConstraints() {
        mostPopularView.translatesAutoresizingMaskIntoConstraints = false
        mostPopularLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        pricePerPeriodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priceLabelCenterYAnchorConstraint = priceLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        priceLabelCenterYAnchorConstraint.isActive = true
        
        priceLabelTopAnchorConstraint = priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        priceLabelTopAnchorConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            // MostPopularView
            mostPopularView.topAnchor.constraint(equalTo: topAnchor),
            mostPopularView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 88),
            mostPopularView.heightAnchor.constraint(equalToConstant: 24),
            
            // MostPopularLabel
            mostPopularLabel.leadingAnchor.constraint(equalTo: mostPopularView.leadingAnchor, constant: 8),
            mostPopularLabel.trailingAnchor.constraint(equalTo: mostPopularView.trailingAnchor, constant: -8),
            mostPopularLabel.centerXAnchor.constraint(equalTo: mostPopularView.centerXAnchor),
            mostPopularLabel.centerYAnchor.constraint(equalTo: mostPopularView.centerYAnchor),
            
            // DurationLabel
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationLabel.heightAnchor.constraint(equalToConstant: 25),
            durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // PriceLabel
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            priceLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: mostPopularView.bounds,
                                byRoundingCorners: [.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        mostPopularView.layer.mask = maskLayer
    }
}
