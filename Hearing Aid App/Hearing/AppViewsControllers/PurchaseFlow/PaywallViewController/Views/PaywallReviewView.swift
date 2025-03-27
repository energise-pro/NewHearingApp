//
//  PaywallReviewView.swift
//  Hearing Aid App

import UIKit

final class PaywallReviewView: UIView {
    // MARK: - Private properties
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = CAppConstants.Images.paywallReviewBackgroundImage
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.appColor(.White100)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.appColor(.White100)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let ratingImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
//        setupGradientView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupView
    
//    private func setupGradientView() {
//        let gradientView = JPBlurView(effectStyle: .systemUltraThinMaterialLight)
//        gradientView.intensity = 0.1
//        gradientView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(gradientView)
//        NSLayoutConstraint.activate([
//            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            gradientView.topAnchor.constraint(equalTo: topAnchor),
//            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//
//        bringSubviewToFront(titleLabel)
//        bringSubviewToFront(descriptionLabel)
//        bringSubviewToFront(ratingImage)
//    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = false
        
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(ratingImage)
        
//        setupConstraints()
    }
    
    //MARK: - Layout
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 300),
            heightAnchor.constraint(equalToConstant: calculateViewHeight()),
            
            // BackgroundImageView
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // TitleLabel
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: ratingImage.leadingAnchor, constant: -4),
            titleLabel.heightAnchor.constraint(equalToConstant: 25),
            
            // RatingImage
            ratingImage.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            ratingImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            ratingImage.heightAnchor.constraint(equalToConstant: 25),
            ratingImage.widthAnchor.constraint(equalToConstant: 106),
            
            // DescriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configureWith(title titleText: String, description descriptionText: String, ratingImage image: UIImage = CAppConstants.Images.paywallRatingImage) {
        titleLabel.text = titleText
        
        let descriptionAttributedString = NSMutableAttributedString(string: descriptionText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12
        
        descriptionAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, descriptionAttributedString.length))
        descriptionLabel.attributedText = descriptionAttributedString
        
        ratingImage.image = image
        
        setupConstraints()
    }
    
    func calculateViewHeight() -> CGFloat {
        let offset = 36.0
        let titleHeight = 25.0
        let descriptionHeight = descriptionLabel.systemLayoutSizeFitting(CGSize(width: 276, height: 999)).height
        return CGFloat(min(145.0, offset + titleHeight + descriptionHeight))
    }
    
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        
//        let colors = [
//            UIColor(red: 7/255, green: 1/255, blue: 29/255, alpha: 0.3).cgColor,
//            UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 0.3).cgColor
//        ]
//        let locations: [CGFloat] = [0.0, 1.0]
//        
//        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                                        colors: colors as CFArray,
//                                        locations: locations) else { return }
//        
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = max(bounds.width, bounds.height) * 0.58  // Adjust this to match your design
//
//        context.drawRadialGradient(gradient,
//                                   startCenter: center,
//                                   startRadius: 0,
//                                   endCenter: center,
//                                   endRadius: radius,
//                                   options: .drawsAfterEndLocation)
//    }
}
