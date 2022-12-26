//
//  RoundedLabel.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 08.12.2022.
//

import UIKit

@IBDesignable
class RoundedLabel: UILabel {

    // MARK: - Public Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var isElipse: Bool = false {
        didSet { cornerRadius = frame.size.height / 2.0 }
    }
}
