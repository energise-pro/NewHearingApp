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
    
    var safeAreaInset: UIEdgeInsets {
        return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }
    
    // MARK: - Internal methods & properties
    var topViewController: UIViewController? {
        return appDelegate?.window?.rootViewController?.topDAppViewController()
    }
    
    var tabBarViewController: TabBarViewController? {
        return appDelegate?.window?.rootViewController as? TabBarViewController
    }
    
    func setTabBarAsRootViewController() {
        let tabBarViewController = TabBarViewController()
        appDelegate?.window?.rootViewController = tabBarViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setNewOnboardingAsRootViewController() {
        let newOnboardingViewController = NewOnboardingViewController()
        appDelegate?.window?.rootViewController = newOnboardingViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func setFakeSplashAsRootViewController() {
        let SFakSplasApViewController = SFakSplasApViewController()
        appDelegate?.window?.rootViewController = SFakSplasApViewController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    @MainActor
    func presentCatchUpAfter(_ duration: TimeInterval, with openAction: GAppAnalyticActions) {
        guard UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasPresentedCatchUp) == false, !TInAppService.shared.isPremium else {
            return
        }
        catchUpTimer?.invalidate()
        catchUpTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            guard UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasPresentedCatchUp) == false else {
                return
            }
            AppsNavManager.shared.presentSCatchUpApViewController(with: openAction)
        }
    }
    
    @MainActor
    func presentSCatchUpApViewController(with openAction: GAppAnalyticActions) {
        guard (topViewController is SpecialOfferBaseViewController) == false, (topViewController is PaywallViewController) == false, !TInAppService.shared.isPremium else {
            return
        }
        if KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_special.rawValue).stringValue == "pw_special_monthly" {
            let specialOfferViewController = SpecialOfferMonthViewController(openAction: openAction)
            specialOfferViewController.modalPresentationStyle = .fullScreen
            topViewController?.present(specialOfferViewController, animated: true)
        } else {
            let specialOfferViewController = SpecialOfferViewController(openAction: openAction)
            specialOfferViewController.modalPresentationStyle = .fullScreen
            topViewController?.present(specialOfferViewController, animated: true)
        }
    }
    
    @MainActor
    func presentSpecialOffer(_ after: Double?, with openAction: GAppAnalyticActions) {
        guard (topViewController is SpecialOfferBaseViewController) == false, !TInAppService.shared.isPremium else {
            return
        }
        if let after = after {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(after)) { [weak self] in
                if KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_special.rawValue).stringValue == "pw_special_monthly" {
                    let specialOfferViewController = SpecialOfferMonthViewController(openAction: openAction)
                    specialOfferViewController.modalPresentationStyle = .fullScreen
                    self?.topViewController?.present(specialOfferViewController, animated: true)
                } else {
                    let specialOfferViewController = SpecialOfferViewController(openAction: openAction)
                    specialOfferViewController.modalPresentationStyle = .fullScreen
                    self?.topViewController?.present(specialOfferViewController, animated: true)
                }
            }
        } else {
            if KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_special.rawValue).stringValue == "pw_special_monthly" {
                let specialOfferViewController = SpecialOfferMonthViewController(openAction: openAction)
                specialOfferViewController.modalPresentationStyle = .fullScreen
                topViewController?.present(specialOfferViewController, animated: true)
            } else {
                let specialOfferViewController = SpecialOfferViewController(openAction: openAction)
                specialOfferViewController.modalPresentationStyle = .fullScreen
                topViewController?.present(specialOfferViewController, animated: true)
            }
        }
    }

    func presentDHeadphsRemindApViewControllerIfNeeded(_ animated: Bool = true, with openAction: GAppAnalyticActions, completion: AppsNavManagerCompletion?) {
        guard !SAudioKitServicesAp.shared.connectedHeadphones else {
            completion?(false)
            return
        }
        let DHeadphsRemindApViewController: HeadphonesConnectViewController = HeadphonesConnectViewController(openAction: openAction)
        DHeadphsRemindApViewController.modalPresentationStyle = .fullScreen
        DHeadphsRemindApViewController.modalTransitionStyle = .crossDissolve
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.topViewController?.present(DHeadphsRemindApViewController, animated: true)
                completion?(true)
            }
        } else {
            topViewController?.present(DHeadphsRemindApViewController, animated: false)
            completion?(true)
        }
    }
    
    func presentDHeadphsRemindApViewController(with openAction: GAppAnalyticActions) {
        guard (topViewController is HeadphonesConnectViewController) == false else { return }
        
        let DHeadphsRemindApViewController: HeadphonesConnectViewController = HeadphonesConnectViewController(openAction: openAction)
        DHeadphsRemindApViewController.modalPresentationStyle = .fullScreen
        DHeadphsRemindApViewController.modalTransitionStyle = .crossDissolve
        #if targetEnvironment(simulator)
        print("presentDHeadphsRemindApViewController")
        #else
        topViewController?.present(DHeadphsRemindApViewController, animated: true)
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
        let FInstructApViewController = HearingInstructionViewController()
        FInstructApViewController.modalPresentationStyle = .fullScreen
        FInstructApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(FInstructApViewController, animated: true)
    }
    
    @MainActor
    func presentSupportViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            openLink(with: CAppConstants.URLs.contactUsURL)
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([CAppConstants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid App Support")
        mailViewController.setMessageBody("<p>My app identificator: \(KAppConfigServic.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    @MainActor
    func presentCancelSubscriptionViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            openLink(with: CAppConstants.URLs.contactUsURL)
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([CAppConstants.General.supportEmail])
        mailViewController.setSubject("Hearing Aid - Cancel subscription")
        mailViewController.setMessageBody("<p>My app identificator: \(KAppConfigServic.shared.settings.userID)<br>\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))</p><br>", isHTML: true)
        topViewController?.present(mailViewController, animated: true)
    }
    
    func presentShareViewController(with activityItems: [Any], and sourceView: UIView?) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .addToReadingList, .openInIBooks, .markupAsPDF]
        activityViewController.popoverPresentationController?.sourceView = sourceView
        topViewController?.present(activityViewController, animated: true)
    }
    
    func presentSReqVoiceRecordApViewController(with openScreenType: OpenScreenType) {
        let SReqVoiceRecordApViewController: SReqVoiceRecordApViewController = SReqVoiceRecordApViewController(with: openScreenType)
        SReqVoiceRecordApViewController.modalPresentationStyle = .fullScreen
        SReqVoiceRecordApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(SReqVoiceRecordApViewController, animated: true)
    }
    
    func presentPaywallViewController(with openAction: GAppAnalyticActions, _ screenType: ВTypPwlScreen? = nil) {
        let paywallScreenType: ВTypPwlScreen
        if let screenType = screenType {
            paywallScreenType = screenType
        } else {
            paywallScreenType = TInAppService.shared.wasUsedTrial ? .regular : .trial
        }
        if KAppConfigServic.shared.remoteConfigValueFor(RemoteConfigKey.Paywall_visual_inapp.rawValue).stringValue == "pw_inapp_monthly" {
            let paywallViewController: PaywallYearMonthViewController = PaywallYearMonthViewController(typeScreen: paywallScreenType, openAction: openAction)
            paywallViewController.modalPresentationStyle = .fullScreen
            paywallViewController.modalTransitionStyle = .crossDissolve
            topViewController?.present(paywallViewController, animated: true)
        } else {
            let paywallViewController: PaywallViewController = PaywallViewController(typeScreen: paywallScreenType, openAction: openAction)
            paywallViewController.modalPresentationStyle = .fullScreen
            paywallViewController.modalTransitionStyle = .crossDissolve
            topViewController?.present(paywallViewController, animated: true)
        }
    }
    
    func presentHMicrophPermisApViewController() {
        let HMicrophPermisApViewController = HMicrophPermisApViewController()
        HMicrophPermisApViewController.modalPresentationStyle = .fullScreen
        HMicrophPermisApViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(HMicrophPermisApViewController, animated: false)
    }
    
    func presentSafariViewController(with link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        safariViewController.preferredControlTintColor = AThemeServicesAp.shared.activeColor
        topViewController?.present(safariViewController, animated: true)
    }
    
    func presentErdSetupViewController(with delegate: ErdSetupViewControllerDelegate?) {
        let ErdSetupViewController = ErdSetupViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: ErdSetupViewController)
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
    
//    func presentZAppIconViewController() {
//        let ZAppIconViewController = ZAppIconViewController()
//        ZAppIconViewController.modalPresentationStyle = .overFullScreen
//        ZAppIconViewController.modalTransitionStyle = .crossDissolve
//        topViewController?.present(ZAppIconViewController, animated: true)
//    }
    
    func presentUTranscribApViewController(and delegate: UTranscribApViewControllerDelegate?) { // {
        let UTranscribApViewController = UTranscribApViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: UTranscribApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentDTypeTextApViewController() {
        let DTypeTextApViewController = DTypeTextApViewController()
        let navigationViewController = UINavigationController(rootViewController: DTypeTextApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentFTextSetupApViewController(with screenType: FTextSetupApViewController.ScreenType, with delegate: FTextSetupApViewControllerDelegate?) {
        let FTextSetupApViewController = FTextSetupApViewController(screenType: screenType, delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: FTextSetupApViewController)
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
    
    func presentLanguangeSetupViewController(with delegate: GLangSetupApViewControllerDelegate?) {
        let GLangSetupApViewController = GLangSetupApViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: GLangSetupApViewController)
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
    
    func pushJLocaleListApViewController(with screenType: JLocaleListApViewController.ScreenType, with delegate: JLocaleListApViewControllerDelegate?) {
        let JLocaleListApViewController = JLocaleListApViewController(screenType: screenType, delegate: delegate)
        topViewController?.navigationController?.pushViewController(JLocaleListApViewController, animated: true)
    }
    
    func presentHTranscriptListApViewController() {
        let HTranscriptListApViewController = HTranscriptListApViewController()
        let navigationViewController = UINavigationController(rootViewController: HTranscriptListApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func pushYTranscriptDetailApViewController(with transcriptModel: TranscribeModel, and delegate: YTranscriptDetailApViewControllerDelegate?) {
        let YTranscriptDetailApViewController = YTranscriptDetailApViewController(transcriptModel: transcriptModel, delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: YTranscriptDetailApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
    func presentJTranslatApViewController(with delegate: JTranslatApViewControllerDelegate?) {
        let JTranslatApViewController = JTranslatApViewController(delegate: delegate)
        let navigationViewController = UINavigationController(rootViewController: JTranslatApViewController)
        topViewController?.present(navigationViewController, animated: true)
    }
    
//    func presentOMoreApViewController() {
//        let OMoreApViewController = OMoreApViewController()
//        let navigationViewController = UINavigationController(rootViewController: OMoreApViewController)
//        topViewController?.present(navigationViewController, animated: true)
//    }
    
    func presentManageSubscription() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
    }
    
    func presentDBPaywlApViewController() {
        let paywallViewController = DBPaywlApViewController()
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .crossDissolve
        topViewController?.present(paywallViewController, animated: true)
    }
    
    func presentTranscriptionInstructionViewController() {
        let instructionVC = TranscriptionInstructionViewController()
        instructionVC.modalPresentationStyle = .fullScreen
        instructionVC.modalTransitionStyle = .crossDissolve
        topViewController?.present(instructionVC, animated: true)
    }
    
    func openLink(_ stringURL: String) {
        guard let url = URL(string: stringURL) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        topViewController?.present(safariVC, animated: true, completion: nil)
    }
    
    func openLink(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        topViewController?.present(safariVC, animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AppsNavManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
