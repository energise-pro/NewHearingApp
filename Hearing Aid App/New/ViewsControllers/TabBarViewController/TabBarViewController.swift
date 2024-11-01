import UIKit
import SwiftUI

final class TabBarViewController: PMBaseViewController {
    
    enum TabBarButton: Int {
        case hearing
        case transcribe
        case settings
        
        var title: String {
            switch self {
            case .hearing:
                return "Hearing Aid".localized()
            case .transcribe:
                return "Speech Recognition".localized()
            case .settings:
                return "Settings".localized()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .hearing:
                return Constants.Images.icTabHearing
            case .transcribe:
                return Constants.Images.icTabMicro
            case .settings:
                return Constants.Images.icTabSettings
            }
        }
        
        var viewController: UIViewController {
            switch self {
            case .hearing:
//                UIStoryboard.init(name: "HearingAidViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "HearingAidViewController")
                return HearingViewController()
            case .transcribe:
//                UIStoryboard.init(name: "SpeechRecognitionViewController", bundle: Bundle.main).instantiateViewController(withIdentifier: "SpeechRecognitionViewController")
                return SpeechViewController()
            case .settings:
                return SettingsViewController()
            }
        }
        
        var analyticAction: GAppAnalyticActions {
            switch self {
            case .hearing:
                return GAppAnalyticActions.hearing
            case .transcribe:
                return GAppAnalyticActions.transcribe
            case .settings:
                return GAppAnalyticActions.settings
            }
        }
    }

    @IBOutlet private var buttonTitles: [UILabel]!
    @IBOutlet private var buttonImages: [UIImageView]!
    
    @IBOutlet private weak var tabBarContainerView: UIView!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    
    private var currentTabIndex: Int?
    private var isPaywallShown: Bool = false
    private var isPermissionShown: Bool = false
    private var headphonesReminderShown: Bool = false
    
    private var navigationControllers: [UINavigationController] = []
    private var tabBarButtons: [TabBarButton] {
        return AppConfiguration.shared.settings.mainScreen == TabBarButton.hearing.rawValue ? [.hearing, .transcribe, .settings] : [.transcribe, .hearing, .settings]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateMainView(with: 0)
        AppConfiguration.shared.settings.appLaunchCount > 1 ? AudioKitService.shared.initializeAudioKit() : Void()
        AppConfiguration.shared.analytics.track(.v2TabBar, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPaywallShown && AppConfiguration.shared.settings.appLaunchCount < 2 {
            NavigationManager.shared.presentBPaywallViewController()
            isPaywallShown = true
        }
        
        if !isPermissionShown && AppConfiguration.shared.settings.appLaunchCount < 2 && NavigationManager.shared.topViewController == self {
            NavigationManager.shared.presentPermissionsListViewController()
            isPermissionShown = true
        }
        
        if !headphonesReminderShown && NavigationManager.shared.topViewController == self && AppConfiguration.shared.settings.mainScreen == 0 {
            !AudioKitService.shared.connectedHeadphones ? NavigationManager.shared.presentHeadphonesReminderViewController() : Void()
            headphonesReminderShown = true
        }
        
        if !AppConfiguration.shared.settings.emailScreenShown && AppConfiguration.shared.settings.appLaunchCount >= 2 && NavigationManager.shared.topViewController == self {
            NavigationManager.shared.presentEmailViewController()
        }
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        guard let currentTabIndex = currentTabIndex else {
            return
        }
        for (titleIndex, _) in buttonTitles.enumerated() {
            buttonTitles[titleIndex].textColor = titleIndex == currentTabIndex ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            buttonImages[titleIndex].tintColor = titleIndex == currentTabIndex ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
        }
    }
    
    func reconfigureUI() {
        configureUI()
    }
    
    // MARK: - Action methods
    @IBAction private func didTapOnTabBarButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        updateMainView(with: sender.tag)
        AppConfiguration.shared.analytics.track(.v2TabBar, with: [GAppAnalyticActions.action.rawValue: tabBarButtons[sender.tag].analyticAction.rawValue])
    }
    
    // MARK: - Private methods
    private func configureUI() {
        navigationControllers = []
        tabBarButtons.enumerated().forEach { (index, item) in
            buttonTitles[index].text = item.title
            buttonImages[index].image = item.image
        }
        for (index, viewController) in tabBarButtons.compactMap({ $0.viewController }).enumerated() {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = index != 2
            navigationControllers.append(navigationController)
            buttonImages[index].tintColor = index == (currentTabIndex ?? 0) ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            buttonTitles[index].textColor = index == (currentTabIndex ?? 0) ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            buttonImages[index].tintAdjustmentMode = .normal
        }
        tabBarContainerView.backgroundColor = UIColor.appColor(.BackgroundColor_1)
        separatorView.backgroundColor = UIColor.appColor(.UnactiveButton_2)
    }

    private func updateMainView(with index: Int) {
        let viewController = navigationControllers[index]
        guard currentTabIndex != index else {
            return
        }
        
        for (titleIndex, _) in buttonTitles.enumerated() {
            buttonTitles[titleIndex].textColor = titleIndex == index ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            buttonImages[titleIndex].tintColor = titleIndex == index ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
        }
        
        if let currentTabIndex = currentTabIndex {
            let oldViewController = navigationControllers[currentTabIndex]
            oldViewController.willMove(toParent: nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParent()
        }
        
        currentTabIndex = index
        
        addChild(viewController)
        viewController.view.frame = mainView.bounds
        mainView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
