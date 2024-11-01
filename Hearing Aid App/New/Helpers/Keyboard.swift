import UIKit

final class KeyboardLayoutConstraint: NSLayoutConstraint {

    // MARK: - Properties
    @IBInspectable var keyboardOffset: CGFloat = 0
    
    private var offset: CGFloat = 0
    private var keyboardVisibleHeight: CGFloat = 0

    private lazy var keyboardNotification = KeyboardNotification()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        offset = constant

        keyboardNotification.keyboardWillShow = { [weak self] notification in
            self?.keyboardWillShowNotification(notification)
        }

        keyboardNotification.keyboardWillHide = { [weak self] notification in
            self?.keyboardWillHideNotification(notification)
        }
    }

    // MARK: - Private methods
    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = frameValue.cgRectValue
            keyboardVisibleHeight = frame.size.height + keyboardOffset
        }

        updateConstant()
        
        switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
        case let (.some(duration), .some(curve)):
            let options = UIView.AnimationOptions(rawValue: curve.uintValue)
            
            UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: options, animations: {
                UIApplication.shared.windows.first?.layoutIfNeeded()
            })
        default:
            break
        }
    }

    @objc private func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        updateConstant()

        guard let userInfo = notification.userInfo else {
            return
        }
        switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
        case let (.some(duration), .some(curve)):
            let options = UIView.AnimationOptions(rawValue: curve.uintValue)

            UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: options, animations: {
                UIApplication.shared.windows.first?.layoutIfNeeded()
            })
        default:
            break
        }
    }

    private func updateConstant() {
        constant = offset + keyboardVisibleHeight
    }
}

final class KeyboardNotification: NSObject {

    // MARK: - Properties
    var keyboardWillShow: ((Notification) -> Void)?
    var keyboardWillHide: ((NSNotification) -> Void)?
    
    var isKeyboardOpened: Bool = false

    // MARK: - Lifecycle
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private methods
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        isKeyboardOpened = true
        keyboardWillShow?(notification)
    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        isKeyboardOpened = false
        keyboardWillHide?(notification)
    }
}
