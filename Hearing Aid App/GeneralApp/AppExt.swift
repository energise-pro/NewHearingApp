import UIKit

extension UIView {
    func addShadow(color: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1),
                   shadowRadius: CGFloat = 5,
                   shadowOffset: CGSize = CGSize(width: 3, height: 4) ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }

    func constraintsToParent(view: UIView) {
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func scale(from: CGFloat, to: CGFloat,
               delay: TimeInterval = 0,
               duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        transform = CGAffineTransform(scaleX: from, y: from)
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction], animations: {
                        self.transform = CGAffineTransform(scaleX: to, y: to)
                       }, completion: completion)
    }

    func fadeIn(from: CGFloat, to: CGFloat,
                delay: TimeInterval = 0,
                duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        alpha = from
        UIView.animate(withDuration: duration, delay: delay,
                       options: [.allowUserInteraction, .curveEaseIn], animations: {
                        self.alpha = to
                       }, completion: completion)
    }

    func animateBackgoundColor(fromColor: UIColor,
                               toColor: UIColor,
                               delay: TimeInterval = 0,
                               duration: TimeInterval = 0.3) {
        backgroundColor = fromColor
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundColor = toColor
        }, completion: nil)
    }

    static let shakingAnimationKey = "shakingAnimationKey"
    func addShakingAnimation(speed: Float = 1.0) {
        if layer.animation(forKey: UIView.shakingAnimationKey) != nil { return }

        let animation = CAKeyframeAnimation(keyPath: "transform")

        let wobbleAngle: CGFloat = speed > 1.0 ? 0.02 : 0.03

        let valLeft = NSValue(caTransform3D: CATransform3DMakeRotation(wobbleAngle, 0.0, 0.0, 1.0))
        let valRight = NSValue(caTransform3D: CATransform3DMakeRotation(-wobbleAngle, 0.0, 0.0, 1.0))

        animation.values = [valLeft,valRight]
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.autoreverses = true
        animation.duration = 0.125
        animation.speed = max(1.0, speed)
        animation.repeatCount = .infinity

        layer.add(animation, forKey: UIView.shakingAnimationKey)
    }

    func removeShakingAnimation() {
        layer.removeAnimation(forKey: UIView.shakingAnimationKey)
    }
}

extension UIViewController {
    func addChildController(_ child: UIViewController,
                            inView container: UIView, withFrame frame: CGRect? = nil,
                            atIndex index: Int? = nil) {
        self.addChild(child)

        if let frame = frame {
            child.view.frame = frame
        } else {
            child.view.frame = container.bounds
        }

        if let index = index {
            container.insertSubview(child.view, at: index)
        } else {
            container.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }

    func removeChildController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    func topDAppViewController() -> UIViewController? {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topDAppViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topDAppViewController()
            }
            return tab.topDAppViewController()
        }
        return self.presentedViewController?.topDAppViewController()
    }
}
extension UITextView {

    @IBInspectable var actionsBar: Bool{
        get {
            return self.actionsBar
        }
        set (hasDone) {
            if hasDone {
                addActionsBar()
            }
        }
    }

    func addActionsBar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = Theme.buttonActiveColor

        let clearText: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearTextAction))
        clearText.tintColor = Theme.buttonActiveColor

        let copyAll: UIBarButtonItem = UIBarButtonItem(title: "Copy All".localized(), style: .plain, target: self, action: #selector(copyAll))
        copyAll.tintColor = Theme.buttonActiveColor

        let items = [clearText,flexSpace,copyAll,flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        resignFirstResponder()
        TapticEngine.impact.feedback(.medium)
    }

    @objc func clearTextAction() {
        UIView.transition(with: self, duration: 0.4,
                          options: [.curveEaseInOut, .transitionCurlUp], animations: {
                            self.text = ""
                            TapticEngine.impact.feedback(.medium)
                          }, completion: nil)
    }

    @objc func copyAll() {
        guard let text = text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        TapticEngine.notification.feedback(.success)
    }
}

extension UIApplication {
    func topDAppViewController() -> UIViewController? {
        return self.windows.first?.rootViewController?.topDAppViewController()
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: [CVarArg]) -> String {
        let stringArguments = arguments.compactMap { "\($0)" }
        return String(format: self.localized(), locale: nil, arguments: stringArguments)
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UITableView {
    func cell(_ view: UIView) -> UITableViewCell? {
        var superview = view.superview
        while superview is UITableViewCell == false && superview != nil {
            superview = superview?.superview
        }

        return superview as? UITableViewCell
    }
}

extension UMainViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
}

extension UIView {
    
    @available(iOS 9, *)
    @discardableResult
    public func addBaseConstraintsFor(view: UIView, layoutGuide: UILayoutGuide? = nil, edgeInsets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
    
        var constraints: [NSLayoutConstraint] = []
        let topAnchor = layoutGuide?.topAnchor ?? self.topAnchor
        let bottomAnchor = layoutGuide?.bottomAnchor ?? self.bottomAnchor
        constraints.append(view.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top))
        constraints.append(view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: edgeInsets.bottom))
        let leftAnchor = layoutGuide?.leftAnchor ?? self.leftAnchor
        let rightAnchor = layoutGuide?.rightAnchor ?? self.rightAnchor
        constraints.append(view.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeInsets.left))
        constraints.append(view.rightAnchor.constraint(equalTo: rightAnchor, constant: edgeInsets.right))
        constraints.forEach { $0.isActive = true }
        
        return constraints
    }
}
