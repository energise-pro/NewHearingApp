import UIKit

extension CGFloat {
    
    static var appHeight: CGFloat {
        return UIApplication.shared.delegate?.window??.rootViewController?.view.frame.height ?? 0.0
    }
    
    static var appWidth: CGFloat {
        return UIApplication.shared.delegate?.window??.rootViewController?.view.frame.width ?? 0.0
    }
}
