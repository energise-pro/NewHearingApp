import UIKit
import SwiftUI

final class TabBarViewController: PMUMainViewController {
    
    enum TabBarButton: Int {
        case hearing
        case transcribe
        case settings
        
        var title: String {
            switch self {
            case .hearing:
                return "Hearing Aid".localized()
            case .transcribe:
                return "Transcription".localized()
            case .settings:
                return "Settings".localized()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .hearing:
                return CAppConstants.Images.icTabHearing
            case .transcribe:
                return CAppConstants.Images.icTabMicro
            case .settings:
                return CAppConstants.Images.icTabSettings
            }
        }
        
        var viewController: UIViewController {
            switch self {
            case .hearing:
                return SHearinApViewController()
            case .transcribe:
                return WSpeechApViewController()
            case .settings:
                return ASettingAppViewController()
            }
        }
        
        var analyticAction: GAppAnalyticActions {
            switch self {
            case .hearing:
                return GAppAnalyticActions.hearingMain
            case .transcribe:
                return GAppAnalyticActions.transcriptionMain
            case .settings:
                return GAppAnalyticActions.settingsMain
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
//    private var isPermissionShown: Bool = false
    private var headphonesReminderShown: Bool = false
    
    private var navigationControllers: [UINavigationController] = []
    private var tabBarButtons: [TabBarButton] {
        return [.hearing, .transcribe, .settings]
//        return KAppConfigServic.shared.settings.mainScreen == TabBarButton.hearing.rawValue ? [.hearing, .transcribe, .settings] : [.transcribe, .hearing, .settings]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateMainView(with: 0)
        KAppConfigServic.shared.settings.appLaunchCount > 1 ? SAudioKitServicesAp.shared.initializeAudioKit() : Void()
        KAppConfigServic.shared.analytics.track(.mainScreenOpened, with: [
            "type" : "hearing_main",
            "hearing_status" : SAudioKitServicesAp.shared.isStartedMixer ? "activated" : "deativated"
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPaywallShown && KAppConfigServic.shared.settings.appLaunchCount < 2 {
            AppsNavManager.shared.presentDBPaywlApViewController()
            isPaywallShown = true
        }
        
//        if !isPermissionShown && KAppConfigServic.shared.settings.appLaunchCount < 2 && AppsNavManager.shared.topViewController == self {
//            AppsNavManager.shared.presentTPermissListApViewController()
//            isPermissionShown = true
//        }
        
//        if !headphonesReminderShown && AppsNavManager.shared.topViewController == self && KAppConfigServic.shared.settings.mainScreen == 0 {
//            !SAudioKitServicesAp.shared.connectedHeadphones ? AppsNavManager.shared.presentDHeadphsRemindApViewController() : Void()
//            headphonesReminderShown = true
//        }
 
    }
    
//    override func didChangeTheme() {
//        super.didChangeTheme()
//        guard let currentTabIndex = currentTabIndex else {
//            return
//        }
//        for (titleIndex, _) in buttonTitles.enumerated() {
//            buttonTitles[titleIndex].textColor = titleIndex == currentTabIndex ? UIColor.appColor(.White100) : UIColor.appColor(.UnactiveButton_2)
//            buttonImages[titleIndex].tintColor = titleIndex == currentTabIndex ? AThemeServicesAp.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
//        }
//    }
    
    func reconfigureUI() {
        configureUI()
    }
    
    // MARK: - Action methods
    @IBAction private func didTapOnTabBarButton(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        updateMainView(with: sender.tag)
        KAppConfigServic.shared.analytics.track(.mainScreenOpened, with: [
            "type" : tabBarButtons[sender.tag].analyticAction.rawValue,
            "hearing_status" : SAudioKitServicesAp.shared.isStartedMixer ? "activated" : "deativated"
        ])
//        KAppConfigServic.shared.analytics.track(.v2TabBar, with: [GAppAnalyticActions.action.rawValue: tabBarButtons[sender.tag].analyticAction.rawValue])
    }
    
    // MARK: - Private methods
    private func configureUI() {
        navigationControllers = []
        print(45444)
        print(tabBarButtons)
        
        tabBarButtons.enumerated().forEach { (index, item) in
            if index < buttonTitles.count && index < buttonImages.count {
                    buttonTitles[index].text = item.title
                    buttonImages[index].image = item.image
                } else {
                    print("Ошибка: индекс \(index) выходит за пределы массива.")
                }
        }
        
        for (index, viewController) in tabBarButtons.compactMap({ $0.viewController }).enumerated() {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            navigationControllers.append(navigationController)
            buttonImages[index].tintColor = index == (currentTabIndex ?? 0) ? AThemeServicesAp.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            buttonTitles[index].textColor = index == (currentTabIndex ?? 0) ? UIColor.appColor(.White100) : UIColor.appColor(.UnactiveButton_2)
            buttonImages[index].tintAdjustmentMode = .normal
        }
        tabBarContainerView.backgroundColor = UIColor.appColor(.BackgroundColor_1)
        separatorView.backgroundColor = UIColor.appColor(.Separator100)
    }

    private func updateMainView(with index: Int) {
        let viewController = navigationControllers[index]
        guard currentTabIndex != index else {
            return
        }
        
        for (titleIndex, _) in buttonTitles.enumerated() {
            buttonTitles[titleIndex].textColor = titleIndex == index ? UIColor.appColor(.White100) : UIColor.appColor(.Grey100)
            buttonImages[titleIndex].tintColor = titleIndex == index ? UIColor.appColor(.Red100) : UIColor.appColor(.Grey100)
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
