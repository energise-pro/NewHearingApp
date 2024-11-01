import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSubscriptionInfo), name: InAppPurchasesService.didUpdatePurchases, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didUpdateSubscriptionInfo() {}

    static func instantiate<T:BaseViewController>() -> T {
        let storyboard = UIStoryboard(name: String(describing:T.self),
                                      bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! T
        return viewController
    }

    func presentAsPopover(vc: UIViewController, sourceView: UIView,
                          height: CGFloat = 300) {
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.preferredContentSize = CGSize(width: 300, height: height)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceView = sourceView
        navigationController.popoverPresentationController?.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
}

extension BaseViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
}

final class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupUIColor()
        NotificationCenter.default.addObserver(self, selector: #selector(setupUIColor), name: ThemeDidChangeNotificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.items?[0].title = "Hearing Aid".localized()
        tabBar.items?[1].title = "Speech Recognition".localized()
        tabBar.items?[2].title = "Settings".localized()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func setupUIColor() {
        Theme.enableDarkMode = false //ThemeSettingsRow.DarkMode.value as? Bool ?? false
        tabBar.tintColor = Theme.buttonActiveColor
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        TapticEngine.impact.feedback(.heavy)
    }
}

class BasePopoverViewController: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppearance()
    }

    func animateAppearance() {
        guard let view = self.view as? VSringlerView else {
            return
        }
        view.animation = "pop"
        view.curve = "easeOut"
        view.duration =  0.8
        view.y = UIScreen.main.bounds.height
        view.animate()
        view.layoutIfNeeded()
    }

    @discardableResult
    static func presentOn<T:BasePopoverViewController>(controller: UIViewController,
                                                       inView view: UIView,
                                                       withSize size: CGSize? = nil) -> T {

        if let existing = controller.children.filter({ $0 is Self }).first as? T {
            return existing
        }

        let popover: T = T.instantiate()

        let frame: CGRect
        if iPhone {
            let width = size?.width ?? UIScreen.main.bounds.size.width - 100
            let height = size?.height ?? width
            frame = CGRect(x: view.center.x - (width / 2),
                           y: view.center.y - (height / 2),
                           width: width, height: height)
        } else {
            let width = size?.width ?? UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 2)
            let height = size?.height ?? width
            frame = CGRect(x: view.center.x - (width / 2),
                           y: view.center.y - (height / 2),
                           width: width, height: height)
        }

        controller.addChildController(popover, inView: view, withFrame: frame)

        return popover
    }


    func remove() {
        parent?.removeChildController(self)
    }

}


func presentError(error: Error? = nil,
                  customTitle: String = "Error".localized(), customDescription: String? = nil) {
    let description = (customDescription ?? error?.localizedDescription) ?? ""
    let errorTitle = customTitle
    let alert = UIAlertController(title: errorTitle, message: description, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
        alert?.dismiss(animated: true, completion: nil)
    }
    alert.addAction(action)
    let vc = UIApplication.shared.topMostViewController()
    vc?.present(alert, animated: true, completion: nil)
}

typealias ConfirmCompletion = () -> Void
typealias DiscardCompletion = () -> Void

func presentAlert(controller: UIViewController,
                  title: String, message: String,
                  completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { _ in
        completion?()
    }
    alert.addAction(action)
    controller.present(alert, animated: true, completion: nil)
}


func presentAlert(controller: UIViewController,
                  title: String, message: String,
                  leftActionTitle: String,
                  rightActionTitle: String,
                  leftActionStyle: UIAlertAction.Style = .cancel,
                  rightActionStyle: UIAlertAction.Style = .default,
                  leftActionCompletion: (() -> Void)? = nil,
                  rightActionCompletion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let actionLeft = UIAlertAction(title: leftActionTitle,
                                   style: leftActionStyle) { _ in
        leftActionCompletion?()
    }
    alert.addAction(actionLeft)

    let actionRight = UIAlertAction(title: rightActionTitle,
                                    style: rightActionStyle) { _ in
        rightActionCompletion?()
    }
    alert.addAction(actionRight)

    controller.present(alert, animated: true, completion: nil)
}

var iPhone: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}
