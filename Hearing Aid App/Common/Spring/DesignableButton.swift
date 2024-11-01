import UIKit

@IBDesignable public class DesignableButton: SpringButton {

    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }

}
