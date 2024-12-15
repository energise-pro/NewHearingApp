import UIKit

enum AlertTimeout: Double {
    case low = 0.95
    case medium = 1.5
    case long = 2.5
}

typealias SimpleCompletion = () -> Void

extension UIViewController {
    
    func presentErrorAlert() {
        presentAlertPM(title: "Oops".localized(), message: "Something went wrong. Please try again".localized())
    }
    
    func presentAlertPM(title: String, message: String, actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions.isEmpty {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
            actions.forEach { alertController.addAction($0) }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentCustomAlert(withMessageText message: String, dismissButtonText dismissText: String, confirmButtonText confirmText: String, delegate alertDelegate: AlertViewControllerDelegate) {
        presentCustomAlert(withMessageText: message, dismissButtonText: dismissText, confirmButtonText: confirmText, checkboxViewText: nil, delegate: alertDelegate)
    }
    
    func presentCustomAlert(withMessageText message: String, dismissButtonText dismissText: String, confirmButtonText confirmText: String, checkboxViewText checkboxText: String?, delegate alertDelegate: AlertViewControllerDelegate) {
        let alertController = AlertViewController(messageText: message, dismissText: dismissText, confirmText: confirmText, checkboxText: checkboxText, delegate: alertDelegate)
        alertController.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: false, completion: nil)
        }
    }
    
    func presentHidingAlert(title: String?, message: String, timeOut: AlertTimeout = .low, completion: (() -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut.rawValue) {
            alertController.dismiss(animated: true)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func presentCustomHidingAlert(message: String, timeOut: AlertTimeout = .low, completion: (() -> ())? = nil) {
        let alertController = ShowMessageViewController(messageText: message)
        alertController.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: false, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut.rawValue) {
            alertController.dismiss(animated: false)
            if let completion = completion {
                completion()
            }
        }
    }
}
