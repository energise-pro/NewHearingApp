import UIKit

extension UIButton {
    
    func startPulseAnimationButton(to value: Double = 1.05, duration: CFTimeInterval = 1.3) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        self.layer.add(animation, forKey: "pulsing")
    }
    
    func stopPulseAnimationButton() {
        layer.removeAnimation(forKey: "pulsing")
    }
}
