import UIKit

enum AssetsColor: String {
    case UnactiveButton_1
    case UnactiveButton_2
    case UnactiveButton_3
    case BackgroundColor_1
    case BackgroundColor_2
    case TextColor_1
    case ActiveColor_1
    case ActiveColor_2
    case Red100
    case White100
    case Separator100
    case Purple100
    case Purple10
    case TableSeparator100
    case Grey100
    case LightGrey20
    case Purple70
    case Purple20
    case Purple50
}

extension UIColor {
    
    convenience init?(hex: String?) {
        guard let hexString = hex else {
            return nil
        }
        
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        if length == 6 {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hexColor: String {
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(redComponent * 255)), lroundf(Float(greenComponent * 255)), lroundf(Float(blueComponent * 255)))
        return hexString
    }
    
    var redComponent: CGFloat {
        return self.cgColor.components![0]
    }
    
    var greenComponent: CGFloat {
        return self.cgColor.components![1]
    }
    
    var blueComponent: CGFloat {
        return self.cgColor.components![2]
    }
    
    static func appColor(_ name: AssetsColor) -> UIColor? {
        return UIColor(named: name.rawValue)
    }
}
