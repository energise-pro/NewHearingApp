//
//  CircleImageView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 08.12.2022.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {
    
    // MARK: - Public Properties
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    // MARK: - Object Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}
