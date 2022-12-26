//
//  GradientView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 09.12.2022.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    // MARK: - Public Properties
    @IBInspectable var startColor: UIColor = .clear {
        didSet { updateColors() }
    }
    
    @IBInspectable var endColor: UIColor = .clear {
        didSet { updateColors() }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var onlyTopCorner: Bool = false {
        didSet { updateCornerRadius() }
    }
    
    override class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    // MARK: - Object Lifecycle
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
    
    // MARK: - Private Methods
    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    private func updateCornerRadius() {
        clipsToBounds = true
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.maskedCorners = onlyTopCorner ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
}
