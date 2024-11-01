import UIKit
import SafariServices
import AVKit
import MessageUI

typealias NavigationManagerCompletion = (_ isSuccess: Bool) -> ()

final class NavigationManager: NSObject {
    
    // MARK: - Properties
    static let shared: NavigationManager = NavigationManager()
    
    private var appDelegate: AppDelegate? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if appDelegate?.window == nil {
            appDelegate?.window = UIWindow(frame: UIScreen.main.bounds)
        }
        return appDelegate
    }
    
    private var catchUpTimer: Timer?
    
    // MARK: - Internal methods & properties
    var topViewController: UIViewController? {
        return appDelegate?.window?.rootViewController?.topMostViewController()
    }
    
    var tabBarViewController: TabBarViewController? {
        return appDelegate?.window?.rootViewController as? TabBarViewController
    }
    
    func setTabBarAsRootViewController() {
        let tabBarViewController = TabBarViewController()
        appDelegate?.window?.rootViewController = tabBarViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setOnboardingAsRootViewController() {
        let onboardingViewController = OnboardingViewController()
        appDelegate?.window?.rootViewController = onboardingViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setFakeSplashAsRootViewController() {
        let fakeSplashViewController = FakeSplashViewController()
        appDelegate?.window?.rootViewController = fakeSplashViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setPreOnboardingAsRootViewController() {
        let preOnboardingViewController = PreOnboardingViewController()
        appDelegate?.window?.rootViewController = preOnboardingViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func presentCatchUpAfter(_ duration: TimeInterval) {
        guard UserDefaults.standard.bool(forKey: Constants.Keys.wasPresentedCatchUp) == false, !InAppPurchasesService.shared.isPremium else {
            return
        }
        catchUpTimer?.invalidate()
        catchUpTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            guard UserDefaults.standard.bool(forKey: Constants.Keys.wasPresentedCatchUp) == false else {
                return
            }
            NavigationManager.shared.presentCatchUpViewController()
        }
    }
    
    func presentCatchUpViewController() {
        guard (topViewController is CatchUpViewController) == false, (topViewController is PaywallViewController) == false, !InAppPurchasesService.shared.isPremium else {
            return
        }
        let catchUpViewController = CatchUpViewController()
        catchUpViewController.modalPresentationStyle = .fullScreen
        topViewController?.present(catchUpViewController, animated: true)
    }

    func presentHeadphonesReminderViewControllerIfNeeded(_ animated: Bool = true, completion: NavigationManagerCompletion?) {
        guard !AudioKitService.shared.connectedHeadphones else {
            completion?(false)
            return
        }
        let headphonesReminderViewController: HeadphonesReminderViewController = HeadphonesReminderViewController()
        headphonesReminderViewController.modalPresentationStyle = .fullScreen
        headphonesReminderViewController.modalTransitionStyle = .crossDissolve
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.topViewController?.present(headphonesReminderViewController, animated: true)
                completion?(true)
            }
        } else {
            topViewController?.present(headphonesReminderViewController, animated: false)
            completion?(true)
        }
    }
    
    func presentHeadphonesReminderViewController() {
        let headphonesReminderViewController: HeadphonesReminderViewController = HeadphonesReminderViewController()
        headphonesReminderViewController.modalPresentationStyle = .fullScreen
        headphonesReminderViewController.modalTransitionStyle = .crossDissolve
        #if targetEnvironment(simulator)
        print("presentHeadphonesReminderViewController")
        #else
        topViewController?.present(headphonesReminderViewController, animated: true)
        #endif
    }
    
    func presentVideoInstructionViewController(with url: URL?) {
        guard let videoURL = url else {
            return
        }
        let player = AVPlayer(url: videoURL)
        let viewController = AVPlayerViewController()
        viewController.player = player
        topViewController?.present(viewController, animated: true) {
            viewController.player?.play()
        }
    }
    
    func presentCustomVideoInstructionViewController() {
        let instructionViewController = InstructionViewController()
        instructionViewController.modalPresentationStyle = .fullScreen
        instructionViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(instructionViewController, animated: true)
    }
    
    func presentSupportViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([Constants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid App Support")
        mailViewController.setMessageBody("<p>My app identificator: \(AppConfigService.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    func presentCancelSubscriptionViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([Constants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid - Cancel subscription")
        mailViewController.setMessageBody("<p>My app identificator: \(AppConfigService.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    func presentShareViewController(with activityItems: [Any], and sourceView: UIView?) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .addToReadingList, .openInIBooks, .markupAsPDF]
        activityViewController.popoverPresentationController?.sourceView = sourceView
        topViewController?.present(activityViewController, animated: true)
    }
    
    func presentRequestVoiceRecordingViewController() {
        let requestVoiceRecordingViewController: RequestVoiceRecordingViewController = RequestVoiceRecordingViewController()
        requestVoiceRecordingViewController.modalPresentationStyle = .fullScreen
        requestVoiceRecordingViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(requestVoiceRecordingViewController, animated: true)
    }
    
    func presentPaywallViewController(with openAction: AnalyticsAction, _ screenType: TypePaywallScreen? = nil) {
        let paywallScreenType: TypePaywallScreen
        if let screenType = screenType {
            paywallScreenType = screenType
        } else {
            paywallScreenType = InAppPurchasesService.shared.wasUsedTrial ? .regular : .trial
        }
        let paywallViewController: PaywallViewController = PaywallViewController(typeScreen: paywallScreenType, openAction: openAction)
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(paywallViewController, animated: true)
    }
    
    func presentMicrophonePermissionViewController() {
        let microphonePermissionViewController = MicrophonePermissionViewController()
        microphonePermissionViewController.modalPresentationStyle = .fullScreen
        microphonePermissionViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(microphonePermissionViewController, animated: false)
    }
    
    func presentSafariViewController(with link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        safariViewController.preferredControlTintColor = ThemeService.shared.activeColor
        topViewController?.present(safariViewController, animated: true)
    }
    
    func presentProSetupViewController(with delegate: ProSetupViewControllerDelegate?) {
        let proSetupViewController = ProSetupViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: proSetupViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentTemplatesViewController(with delegate: TemplatesViewControllerDelegate?) {
        let templatesViewController = TemplatesViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: templatesViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func pushCompressorViewController() {
        let compressorViewController = CompressorViewController()
        topViewController?.navigationController?.pushViewController(compressorViewController, animated: true)
    }
    
    func pushVoiceChangerViewController() {
        let voiceChangerViewController = VoiceChangerViewController()
        topViewController?.navigationController?.pushViewController(voiceChangerViewController, animated: true)
    }
    
    func pushLimiterViewController() {
        let limiterViewController = LimiterViewController()
        topViewController?.navigationController?.pushViewController(limiterViewController, animated: true)
    }
    
    func pushEqualizerViewController() {
        let equalizerViewController = EqualizerViewController()
        topViewController?.navigationController?.pushViewController(equalizerViewController, animated: true)
    }
    
    func presentAppIconsViewController() {
        let appIconsViewController = AppIconsViewController()
        appIconsViewController.modalPresentationStyle = .overFullScreen
        appIconsViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(appIconsViewController, animated: true)
    }
    
    func presentTranscribeViewController() {
        let transcribeViewController = TranscribeViewController()
        let navigationViewController = UINavigationController(rootViewController: transcribeViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentTypeTextViewController() {
        let typeTextViewController = TypeTextViewController()
        let navigationViewController = UINavigationController(rootViewController: typeTextViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentTextSetupViewController(with screenType: TextSetupViewController.ScreenType, with delegate: TextSetupViewControllerDelegate?) {
        let textSetupViewController = TextSetupViewController(screenType: screenType, delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: textSetupViewController)
        navigationViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheetViewController = navigationViewController.sheetPresentationController {
                sheetViewController.detents = [.medium()]
                sheetViewController.prefersScrollingExpandsWhenScrolledToEdge = false
                sheetViewController.prefersEdgeAttachedInCompactHeight = true
                sheetViewController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            topViewController?.present(navigationViewController, animated: true, completion: nil)
        } else {
            topViewController?.present(navigationViewController, animated: true)
        }
    }
    
    func presentLanguangeSetupViewController(with delegate: LanguageSetupViewControllerDelegate?) {
        let languageSetupViewController = LanguageSetupViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: languageSetupViewController)
        navigationViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheetViewController = navigationViewController.sheetPresentationController {
                sheetViewController.detents = [.medium()]
                sheetViewController.prefersScrollingExpandsWhenScrolledToEdge = false
                sheetViewController.prefersEdgeAttachedInCompactHeight = true
                sheetViewController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            topViewController?.present(navigationViewController, animated: true, completion: nil)
        } else {
            topViewController?.present(navigationViewController, animated: true)
        }
    }
    
    func pushLocalesListViewController(with screenType: LocalesListViewController.ScreenType, with delegate: LocalesListViewControllerDelegate?) {
        let localesListViewController = LocalesListViewController(screenType: screenType, delegate: delegate)
        topViewController?.navigationController?.pushViewController(localesListViewController, animated: true)
    }
    
    func presentTranscriptsListViewController() {
        let transcriptsListViewController = TranscriptsListViewController()
        let navigationViewController = UINavigationController(rootViewController: transcriptsListViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func pushTranscriptDetailsViewController(with transcriptModel: TranscribeModel, and delegate: TranscriptDetailsViewControllerDelegate?) {
        let transcriptDetailsViewController = TranscriptDetailsViewController(transcriptModel: transcriptModel, delegate: delegate)
        topViewController?.navigationController?.pushViewController(transcriptDetailsViewController, animated: true)
    }
    
    func presentTranslateViewController() {
        let translateViewController = TranslateViewController()
        let navigationViewController = UINavigationController(rootViewController: translateViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentMoreViewController() {
        let moreViewController = MoreViewController()
        let navigationViewController = UINavigationController(rootViewController: moreViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentManageSubscription() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
    }
    
    func presentEmailViewController() {
        let emailViewController = EmailViewController()
        emailViewController.modalPresentationStyle = .fullScreen
        emailViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(emailViewController, animated: true)
    }
    
    func presentPermissionsListViewController() {
        let permissionsListViewController = PermissionsListViewController()
        permissionsListViewController.modalPresentationStyle = .fullScreen
        permissionsListViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(permissionsListViewController, animated: true)
    }
    
    func presentCrossPromoViewController() {
        let crossPromoViewController = CrossPromoViewController()
        crossPromoViewController.modalPresentationStyle = .fullScreen
        crossPromoViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(crossPromoViewController, animated: true)
    }
    
    func presentBPaywallViewController() {
        let paywallViewController = BPaywallViewController()
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(paywallViewController, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension NavigationManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
