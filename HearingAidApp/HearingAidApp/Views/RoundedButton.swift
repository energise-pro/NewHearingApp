//
//  RoundedButton.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 07.12.2022.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    // MARK: - Public Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
}
