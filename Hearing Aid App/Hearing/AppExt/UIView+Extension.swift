import UIKit


extension UIView {
    
    func pulseAnimation(to value: Double = 1.05, duration: CFTimeInterval = 1.3) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        self.layer.add(animation, forKey: "pulsing")
    }
    
    func stopPulseAnimation() {
        layer.removeAnimation(forKey: "pulsing")
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func animateHidden(_ hidden: Bool, duration: Double = 0.3, delay: Double = 0.0, completion: (() -> Void)? = nil) {
        if self.isHidden && !hidden {
            self.alpha = 0.0
            self.isHidden = false
        }
        UIView.animate(withDuration: duration, delay: delay, animations: {
            self.alpha = hidden ? 0.0 : 1.0
        }, completion: { _ in
            self.isHidden = hidden
            completion?()
        })
    }
    
    private enum Defaults {
        static let gradientLayerName = "gradientLayerName"
    }
    
    func addGradient(_ colors: [UIColor], isHorizontal: Bool) {
        removeGradient()
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Defaults.gradientLayerName
        gradientLayer.opacity = 1.0
        gradientLayer.colors = colors.map { $0.cgColor }
        
        if isHorizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        
        gradientLayer.frame = bounds
        if let button: UIButton = self as? UIButton, let imageViewLayer: CALayer = button.imageView?.layer {
            button.layer.insertSublayer(gradientLayer, below: imageViewLayer)
        } else {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func removeGradient() {
        layer.sublayers?.removeAll(where: { $0.name == Defaults.gradientLayerName })
    }
}

extension UISegmentedControl {
    
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
