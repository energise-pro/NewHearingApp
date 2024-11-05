import UIKit

extension UIView {
    
//    @IBInspectable var layerMasksToBounds: Bool {
//        set { layer.masksToBounds = newValue }
//        get { return layer.masksToBounds }
//    }
    
//    @IBInspectable var isRoundedSides: Bool {
//        set { layer.cornerRadius = newValue ? min(layer.bounds.width, layer.bounds.height) / 2.0 : 0.0 }
//        get { return layer.cornerRadius == min(layer.bounds.width, layer.bounds.height) / 2.0 }
//    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    // MARK: - Border
//    @IBInspectable var borderWidthPM: CGFloat {
//        set { layer.borderWidth = newValue }
//        get { return layer.borderWidth }
//    }
//
//    @IBInspectable var borderColorPM: UIColor? {
//        set { layer.borderColor = newValue?.cgColor }
//        get { return UIColor(cgColor: layer.borderColor!) }
//    }
    
    // MARK: - Shadow
    
//    @IBInspectable var shadowOffsetPM: CGSize {
//        set { layer.shadowOffset = newValue }
//        get { return layer.shadowOffset }
//    }
//
//    @IBInspectable var shadowOpacityPM: Float {
//        set { layer.shadowOpacity = newValue }
//        get { return layer.shadowOpacity }
//    }
//
//    @IBInspectable var shadowRadiusPM: CGFloat {
//        set { layer.shadowRadius = newValue }
//        get { return layer.shadowRadius }
//    }
//
//    @IBInspectable var shadowColorPM: UIColor? {
//        set { layer.shadowColor = newValue?.cgColor }
//        get { return UIColor(cgColor: layer.shadowColor!) }
//    }
//
//    @IBInspectable var isShadowPathPM: Bool {
//        set {
//            if newValue {
//                layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
//            } else {
//                layer.shadowPath = nil
//            }
//        } get { return layer.shadowPath != nil }
//    }
}


