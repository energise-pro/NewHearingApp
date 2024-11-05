import UIKit

extension UITextView {
    
    func addActionBar(with actions: [UIBarButtonItem]) {
        let customToolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: .appWidth, height: 50.0)))
        customToolbar.barStyle = .default
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        var items: [UIBarButtonItem] = []
        actions.enumerated().forEach {
            $0.element.tintColor = AThemeServicesAp.shared.activeColor
            if ($0.offset == actions.count - 1) {
                items.append($0.element)
            } else {
                items.append($0.element)
                items.append(flexibleSpace)
            }
        }
        
        customToolbar.items = items
        customToolbar.sizeToFit()
        
        inputAccessoryView = customToolbar
    }
}
