//
//  CroppedImageView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 08.12.2022.
//

import UIKit

class CroppedImageView: UIImageView {
    
    // MARK: - Object Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShapeLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShapeLayer()
    }
    
    // MARK: - Private Methods
    private func addShapeLayer() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.size.width, y: 0))
        path.addCurve(to: CGPoint(x: frame.size.width, y: frame.size.height * 0.8),
                             controlPoint1: CGPoint(x: frame.size.width, y: 0),
                             controlPoint2: CGPoint(x: frame.size.width, y: frame.size.height / 2.0))
        path.addCurve(to: CGPoint(x: 0, y: frame.size.height * 0.85),
                             controlPoint1: CGPoint(x: frame.size.width * 0.4, y: frame.size.height - 5),
                             controlPoint2: CGPoint(x: 0, y: frame.size.height * 0.85))
        path.addCurve(to: CGPoint(x: 0, y: 0),
                             controlPoint1: CGPoint(x: 0, y: frame.size.height / 2.0),
                             controlPoint2: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: frame.size.width, y: 0))
        path.close()
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        self.layer.mask = layer
    }
}
