import UIKit
import SafariServices
import AVKit
import MessageUI

typealias AppsNavManagerCompletion = (_ isSuccess: Bool) -> ()

final class AppsNavManager: NSObject {
    
    // MARK: - Properties
    static let shared: AppsNavManager = AppsNavManager()
    
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
        return appDelegate?.window?.rootViewController?.topDAppViewController()
    }
    
    var tabBarViewController: AppTabBarViewController? {
        return appDelegate?.window?.rootViewController as? AppTabBarViewController
    }
    
    func setTabBarAsRootViewController() {
        let tabBarViewController = AppTabBarViewController()
        appDelegate?.window?.rootViewController = tabBarViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setOnboardingAsRootViewController() {
        let FOnboardApViewController = FOnboardApViewController()
        appDelegate?.window?.rootViewController = FOnboardApViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setFakeSplashAsRootViewController() {
        let fakeSplashViewController = FakeSplashViewController()
        appDelegate?.window?.rootViewController = fakeSplashViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setPreOnboardingAsRootViewController() {
        let GPOnboardApViewController = GPOnboardApViewController()
        appDelegate?.window?.rootViewController = GPOnboardApViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func presentCatchUpAfter(_ duration: TimeInterval) {
        guard UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasPresentedCatchUp) == false, !InAppPurchasesService.shared.isPremium else {
            return
        }
        catchUpTimer?.invalidate()
        catchUpTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            guard UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasPresentedCatchUp) == false else {
                return
            }
            AppsNavManager.shared.presentSCatchUpApViewController()
        }
    }
    
    func presentSCatchUpApViewController() {
        guard (topViewController is SCatchUpApViewController) == false, (topViewController is PaywallViewController) == false, !InAppPurchasesService.shared.isPremium else {
            return
        }
        let SCatchUpApViewController = SCatchUpApViewController()
        SCatchUpApViewController.modalPresentationStyle = .fullScreen
        topViewController?.present(SCatchUpApViewController, animated: true)
    }

    func presentAHeadphRemindApViewControllerIfNeeded(_ animated: Bool = true, completion: AppsNavManagerCompletion?) {
        guard !AudioKitService.shared.connectedHeadphones else {
            completion?(false)
            return
        }
        let AHeadphRemindApViewController: AHeadphRemindApViewController = AHeadphRemindApViewController()
        AHeadphRemindApViewController.modalPresentationStyle = .fullScreen
        AHeadphRemindApViewController.modalTransitionStyle = .crossDissolve
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.topViewController?.present(AHeadphRemindApViewController, animated: true)
                completion?(true)
            }
        } else {
            topViewController?.present(AHeadphRemindApViewController, animated: false)
            completion?(true)
        }
    }
    
    func presentAHeadphRemindApViewController() {
        let AHeadphRemindApViewController: AHeadphRemindApViewController = AHeadphRemindApViewController()
        AHeadphRemindApViewController.modalPresentationStyle = .fullScreen
        AHeadphRemindApViewController.modalTransitionStyle = .crossDissolve
        #if targetEnvironment(simulator)
        print("presentAHeadphRemindApViewController")
        #else
        topViewController?.present(AHeadphRemindApViewController, animated: true)
        #endif
    }
    
    func presentVideoFInstructApViewController(with url: URL?) {
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
    
    func presentCustomVideoFInstructApViewController() {
        let FInstructApViewController = FInstructApViewController()
        FInstructApViewController.modalPresentationStyle = .fullScreen
        FInstructApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(FInstructApViewController, animated: true)
    }
    
    func presentSupportViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([CAppConstants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid App Support")
        mailViewController.setMessageBody("<p>My app identificator: \(AppConfiguration.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    func presentCancelSubscriptionViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([CAppConstants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid - Cancel subscription")
        mailViewController.setMessageBody("<p>My app identificator: \(AppConfiguration.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    func presentShareViewController(with activityItems: [Any], and sourceView: UIView?) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .addToReadingList, .openInIBooks, .markupAsPDF]
        activityViewController.popoverPresentationController?.sourceView = sourceView
        topViewController?.present(activityViewController, animated: true)
    }
    
    func presentSReqVoiceRecordApViewController() {
        let SReqVoiceRecordApViewController: SReqVoiceRecordApViewController = SReqVoiceRecordApViewController()
        SReqVoiceRecordApViewController.modalPresentationStyle = .fullScreen
        SReqVoiceRecordApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(SReqVoiceRecordApViewController, animated: true)
    }
    
    func presentPaywallViewController(with openAction: GAppAnalyticActions, _ screenType: ВTypPwlScreen? = nil) {
        let paywallScreenType: ВTypPwlScreen
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
    
    func presentHMicrophPermisApViewController() {
        let HMicrophPermisApViewController = HMicrophPermisApViewController()
        HMicrophPermisApViewController.modalPresentationStyle = .fullScreen
        HMicrophPermisApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(HMicrophPermisApViewController, animated: false)
    }
    
    func presentSafariViewController(with link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        safariViewController.preferredControlTintColor = ThemeService.shared.activeColor
        topViewController?.present(safariViewController, animated: true)
    }
    
    func presentEPSetupApViewController(with delegate: EPSetupApViewControllerDelegate?) {
        let EPSetupApViewController = EPSetupApViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: EPSetupApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentQTemplateApViewController(with delegate: QTemplateApViewControllerDelegate?) {
        let QTemplateApViewController = QTemplateApViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: QTemplateApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func pushKCompresViewController() {
        let KCompresViewController = KCompresViewController()
        topViewController?.navigationController?.pushViewController(KCompresViewController, animated: true)
    }
    
    func pushRVoicChangeJViewController() {
        let RVoicChangeJViewController = RVoicChangeJViewController()
        topViewController?.navigationController?.pushViewController(RVoicChangeJViewController, animated: true)
    }
    
    func pushYLimitApViewController() {
        let YLimitApViewController = YLimitApViewController()
        topViewController?.navigationController?.pushViewController(YLimitApViewController, animated: true)
    }
    
    func pushUEqualizeApViewController() {
        let UEqualizeApViewController = UEqualizeApViewController()
        topViewController?.navigationController?.pushViewController(UEqualizeApViewController, animated: true)
    }
    
    func presentZAppIconViewController() {
        let ZAppIconViewController = ZAppIconViewController()
        ZAppIconViewController.modalPresentationStyle = .overFullScreen
        ZAppIconViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(ZAppIconViewController, animated: true)
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
    
    func presentOMoreApViewController() {
        let OMoreApViewController = OMoreApViewController()
        let navigationViewController = UINavigationController(rootViewController: OMoreApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentManageSubscription() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
    }
    
    func presentWEmailApViewController() {
        let WEmailApViewController = WEmailApViewController()
        WEmailApViewController.modalPresentationStyle = .fullScreen
        WEmailApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(WEmailApViewController, animated: true)
    }
    
    func presentTPermissListApViewController() {
        let TPermissListApViewController = TPermissListApViewController()
        TPermissListApViewController.modalPresentationStyle = .fullScreen
        TPermissListApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(TPermissListApViewController, animated: true)
    }
    
    func presentCrossPromoViewController() {
        let crossPromoViewController = CrossPromoViewController()
        crossPromoViewController.modalPresentationStyle = .fullScreen
        crossPromoViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(crossPromoViewController, animated: true)
    }
    
    func presentDBPaywlApViewController() {
        let paywallViewController = DBPaywlApViewController()
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(paywallViewController, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AppsNavManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
