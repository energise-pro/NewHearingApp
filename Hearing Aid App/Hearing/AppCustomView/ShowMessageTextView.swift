//
//  ShowMessageTextView.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 15.12.2024.
//

import UIKit

class ShowMessageTextView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .clear
        
        self.layer.shadowColor = UIColor(red: 97/255, green: 83/255, blue: 143/255, alpha: 0.08).cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 12
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let stretchedPath = stretchBezierPathHorizontally(toFitWidthIn: self)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = stretchedPath.cgPath
        shapeLayer.fillColor = UIColor.appColor(.White100)?.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    func stretchBezierPathHorizontally(toFitWidthIn view: UIView) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 254.65, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 258.78, y: 3.56), controlPoint1: CGPoint(x: 256.7, y: 0), controlPoint2: CGPoint(x: 258.39, y: 1.55))
        bezierPath.addCurve(to: CGPoint(x: 298.37, y: 38.57), controlPoint1: CGPoint(x: 262.44, y: 22.61), controlPoint2: CGPoint(x: 278.58, y: 37.23))
        bezierPath.addCurve(to: CGPoint(x: 301.93, y: 40.72), controlPoint1: CGPoint(x: 299.83, y: 38.67), controlPoint2: CGPoint(x: 301.15, y: 39.48))
        bezierPath.addCurve(to: CGPoint(x: 329.5, y: 56), controlPoint1: CGPoint(x: 307.68, y: 49.9), controlPoint2: CGPoint(x: 317.88, y: 56))
        bezierPath.addCurve(to: CGPoint(x: 337.12, y: 55.1), controlPoint1: CGPoint(x: 332.12, y: 56), controlPoint2: CGPoint(x: 334.68, y: 55.69))
        bezierPath.addCurve(to: CGPoint(x: 343, y: 59.3), controlPoint1: CGPoint(x: 339.95, y: 54.42), controlPoint2: CGPoint(x: 343, y: 56.39))
        bezierPath.addLine(to: CGPoint(x: 343, y: 76))
        bezierPath.addCurve(to: CGPoint(x: 331, y: 88), controlPoint1: CGPoint(x: 343, y: 82.63), controlPoint2: CGPoint(x: 337.63, y: 88))
        bezierPath.addLine(to: CGPoint(x: 12, y: 88))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 76), controlPoint1: CGPoint(x: 5.37, y: 88), controlPoint2: CGPoint(x: 0, y: 82.63))
        bezierPath.addLine(to: CGPoint(x: 0, y: 12))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 0), controlPoint1: CGPoint(x: 0, y: 5.37), controlPoint2: CGPoint(x: 5.37, y: 0))
        bezierPath.addLine(to: CGPoint(x: 254.65, y: 0))
        bezierPath.close()

        let boundingBox = bezierPath.bounds
        let originalWidth = boundingBox.width
        let targetWidth = view.bounds.width
        let scaleFactorX = targetWidth / originalWidth

        let transform = CGAffineTransform.identity
            .scaledBy(x: scaleFactorX, y: 1.0)
            .translatedBy(x: -boundingBox.origin.x * scaleFactorX, y: -boundingBox.origin.y)

        bezierPath.apply(transform)
        return bezierPath
    }
}
