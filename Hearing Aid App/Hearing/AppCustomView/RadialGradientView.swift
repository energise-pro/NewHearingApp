//
//  RadialGradientView.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 15.11.2024.
//

import UIKit

final class RadialGradientView: UIView {
    private let label = UILabel()
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContent()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.masksToBounds = true

        let gradientView = JPBlurView(effectStyle: .systemUltraThinMaterialLight)
        gradientView.intensity = 0.1
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        bringSubviewToFront(imageView)
        bringSubviewToFront(label)
    }
    
    private func setupContent() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.White100)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        addSubview(imageView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colors = [
            UIColor(red: 7/255, green: 1/255, blue: 29/255, alpha: 0.3).cgColor,
            UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 0.3).cgColor
        ]
        let locations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: locations) else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = max(bounds.width, bounds.height) * 0.58  // Adjust this to match your design

        context.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: radius,
                                   options: .drawsAfterEndLocation)
    }
    
    func configure(withText text: String, image: UIImage?) {
        label.text = text
        imageView.image = image
    }
}
