//
//  RoundedView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 08.12.2022.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    // MARK: - Public Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet { layer.shadowRadius = shadowRadius }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet { layer.shadowOpacity = shadowOpacity }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }
    
    @IBInspectable var shadowOffsetX: CGFloat = 0 {
        didSet { layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY) }
    }
    
    @IBInspectable var shadowOffsetY: CGFloat = 0 {
        didSet { layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY) }
    }
}
