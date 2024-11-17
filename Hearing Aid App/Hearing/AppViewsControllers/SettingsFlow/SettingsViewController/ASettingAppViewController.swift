import UIKit

enum SettingAppViewControllerCellId: String {
    case rateAppCell
    case shareAppCell
    case hapticCell
    case restorePurchasesCell
    case supportCell
    case submitCompliantCell
    case privacyPolicyCell
    case termsOfUseCell
}

final class ASettingAppViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var topViewHeight: NSLayoutConstraint! // If not premium 232.0, else 0.0
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var premiumBannerView: UIView! // Hide if premium
    @IBOutlet private weak var premiumBannerTitle: UILabel!
    @IBOutlet private weak var premiumBannerSubtitle: UILabel!
    @IBOutlet private weak var premiumBannerButton: UIButton!
    
    private var dataSource: [CellConfigurator] = []
    private var firstSectionDataSource: [CellConfigurator] = []
    private var secondSectionDataSource: [CellConfigurator] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSubscriptionInfo), name: TInAppService.didUpdatePurchases, object: nil)
        configureUI()
        configureDataSource()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    override func didChangeTheme() {
//        super.didChangeTheme()
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AThemeServicesAp.shared.activeColor as Any, .font: UIFont.systemFont(ofSize: 28.0, weight: .bold) as Any]
//    }
    
    // MARK: - Private methods
    private func configureUI() {
        titleLabel.text = "Settings".localized()
        premiumBannerTitle.text = "Get Full Access".localized()
        premiumBannerSubtitle.text = "Unlock Premium to hear with clarity".localized()
        premiumBannerButton.titleLabel?.text = "Try Free & Subscribe".localized()
        
        tableView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
        
        let cellNibs: [UIViewCellNib.Type] = [NewSettingTableViewCell.self, NewSettingTableViewEmptyCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
        
        premiumBannerView.isHidden = TInAppService.shared.isPremium
        topViewHeight.constant = TInAppService.shared.isPremium ? 0.0 : 232.0
        view.layoutSubviews()
    }
    
    private func configureDataSource() {
        let emptyCellModel = NewSettingTableViewEmptyCellModel()
        let emptyCellConfig = NewSettingTableViewEmptyCellConfig(item: emptyCellModel, height: 15.0)
        
        var rateAppCellModel = NewSettingTableViewCellModel(title: "Rate App".localized(), buttonTypes: [.rightButton, .leftButtonImage], leftImage: UIImage(named: "settingRateImage"), delegate: self)
        rateAppCellModel.cellId = SettingAppViewControllerCellId.rateAppCell.rawValue
        let rateAppCellConfig = NewSettingTableViewCellConfig(item: rateAppCellModel, height: 44.0)
        
        var shareAppCellModel = NewSettingTableViewCellModel(title: "Share App".localized(), buttonTypes: [.rightButton, .leftButtonImage], leftImage: UIImage(named: "settingShareImage"), delegate: self)
        shareAppCellModel.cellId = SettingAppViewControllerCellId.shareAppCell.rawValue
        let shareAppCellConfig = NewSettingTableViewCellConfig(item: shareAppCellModel, height: 44.0)
        
        let betweenSectionCellModel = NewSettingTableViewEmptyCellModel()
        let betweenSectionCellConfig = NewSettingTableViewEmptyCellConfig(item: betweenSectionCellModel, height: 32.0)
        
        var hapticCellModel = NewSettingTableViewCellModel(title: "Use Haptic Feedback".localized(), buttonTypes: [.info, .switchButton], switchState: TapticEngine.isOn, delegate: self)
        hapticCellModel.cellId = SettingAppViewControllerCellId.hapticCell.rawValue
        let hapticCellConfig = NewSettingTableViewCellConfig(item: hapticCellModel, height: 44.0)
        
        var restorePurchasesCellModel = NewSettingTableViewCellModel(title: "Restore Purchases".localized(), buttonTypes: [.rightButton], delegate: self)
        restorePurchasesCellModel.cellId = SettingAppViewControllerCellId.restorePurchasesCell.rawValue
        let restorePurchasesCellConfig = NewSettingTableViewCellConfig(item: restorePurchasesCellModel, height: 44.0)
        
        var supportCellModel = NewSettingTableViewCellModel(title: "Support & Contact Us".localized(), buttonTypes: [.rightButton], delegate: self)
        supportCellModel.cellId = SettingAppViewControllerCellId.supportCell.rawValue
        let supportCellConfig = NewSettingTableViewCellConfig(item: supportCellModel, height: 44.0)
        supportCellConfig.height = 44.0
        
        var submitCompliantCellModel = NewSettingTableViewCellModel(title: "Submit a Compliant".localized(), buttonTypes: [.rightButton], delegate: self)
        submitCompliantCellModel.cellId = SettingAppViewControllerCellId.submitCompliantCell.rawValue
        let submitCompliantCellConfig = NewSettingTableViewCellConfig(item: submitCompliantCellModel, height: 44.0)
        
        var privacyPolicyCellModel = NewSettingTableViewCellModel(title: "Privacy Policy".localized(), buttonTypes: [.rightButton], delegate: self)
        privacyPolicyCellModel.cellId = SettingAppViewControllerCellId.privacyPolicyCell.rawValue
        let privacyPolicyCellConfig = NewSettingTableViewCellConfig(item: privacyPolicyCellModel, height: 44.0)
        
        var termsOfUseCellModel = NewSettingTableViewCellModel(title: "Terms of Use".localized(), buttonTypes: [.rightButton], delegate: self)
        termsOfUseCellModel.cellId = SettingAppViewControllerCellId.termsOfUseCell.rawValue
        let termsOfUseCellConfig = NewSettingTableViewCellConfig(item: termsOfUseCellModel, height: 44.0)
        
        firstSectionDataSource = [rateAppCellConfig, emptyCellConfig, shareAppCellConfig, betweenSectionCellConfig]
        secondSectionDataSource = [hapticCellConfig, emptyCellConfig, restorePurchasesCellConfig, emptyCellConfig, supportCellConfig, emptyCellConfig, submitCompliantCellConfig, emptyCellConfig, privacyPolicyCellConfig, emptyCellConfig, termsOfUseCellConfig]
        dataSource = firstSectionDataSource + secondSectionDataSource
        tableView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func onPremiumBannerTap(_ sender: UITapGestureRecognizer) {
        AppsNavManager.shared.presentPaywallViewController(with: .openFromSetting)
    }
    
    @objc func didUpdateSubscriptionInfo() {
        premiumBannerView.isHidden = TInAppService.shared.isPremium
        topViewHeight.constant = TInAppService.shared.isPremium ? 0.0 : 232.0
        view.layoutSubviews()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ASettingAppViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? firstSectionDataSource.count : secondSectionDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellConfig: CellConfigurator
        if indexPath.section == 0 {
            cellConfig = firstSectionDataSource[indexPath.row]
        } else {
            cellConfig = secondSectionDataSource[indexPath.row]
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfig.identifier, for: indexPath)
        cellConfig.configure(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightForRow: CGFloat?
        if indexPath.section == 0 {
            heightForRow = firstSectionDataSource[indexPath.row].height
        } else {
            heightForRow = secondSectionDataSource[indexPath.row].height
        }
        return heightForRow ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let estimatedHeightForRow: CGFloat?
        if indexPath.section == 0 {
            estimatedHeightForRow = firstSectionDataSource[indexPath.row].height
        } else {
            estimatedHeightForRow = secondSectionDataSource[indexPath.row].height
        }
        return estimatedHeightForRow ?? UITableView.automaticDimension
    }
}

// MARK: - NewSettingTableViewCellDelegate
extension ASettingAppViewController: NewSettingTableViewCellDelegate {
    
    func didSelectButton(with type: NewSettingTableViewButtonType, from cell: NewSettingTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let itemModel = indexPath.section == 0 ? firstSectionDataSource[indexPath.row].getItem() : secondSectionDataSource[indexPath.row].getItem()
        guard let cellModel = itemModel as? NewSettingTableViewCellModel, let cellIdRawValue = cellModel.cellId else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        let cellId = SettingAppViewControllerCellId(rawValue: cellIdRawValue)
        switch cellId {
        case .rateAppCell: // Rate app
            KAppConfigServic.shared.settings.presentAppRatingAlert()
        case .shareAppCell: // Share app
            AppsNavManager.shared.presentShareViewController(with: [CAppConstants.URLs.appStoreUrl], and: nil)
        case .hapticCell: // Haptic
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "Disable or Enable vibrations when you press UI buttons".localized())
                
                KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.haptic.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !TapticEngine.isOn
                TapticEngine.isOn = newState
                //ThemeSettingsRow.TapticOption.setValue(newState)

                var newCellModel = NewSettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, topInset: cellModel.topInset, delegate: self)
                newCellModel.cellId = SettingAppViewControllerCellId.hapticCell.rawValue
                secondSectionDataSource[indexPath.row] = NewSettingTableViewCellConfig(item: newCellModel)

                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.haptic.rawValue)_\(stringState)"])
            default:
                break
            }
        case .restorePurchasesCell: // Restore
            HAppLoaderView.showLoader(at: AppsNavManager.shared.topViewController?.view ?? view, animated: true)
            TInAppService.shared.restorePurchases { [weak self] isSuccess in
                guard let self = self else {
                    return
                }
                HAppLoaderView.hideLoader(for: AppsNavManager.shared.topViewController?.view ?? self.view, animated: true)
                let title = isSuccess ? "Purchases successfully restored".localized() : "Oops".localized()
                let message = isSuccess ? "" : "You have not purchases yet".localized()
                isSuccess ? self.presentHidingAlert(title: title, message: message) : self.presentAlertPM(title: title, message: message)
            }
            
            KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.restore.rawValue])
        case .supportCell: // Support
            AppsNavManager.shared.presentSupportViewController()
            
            KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.support.rawValue])
        case .submitCompliantCell: // Submit Compliant
            AppsNavManager.shared.presentSupportViewController()
        case .privacyPolicyCell: // Privacy Policy
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.privacyPolicyURL)
        case .termsOfUseCell: // Terms of use
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.termsURL)
        default:
            break
        }
    }
}

private struct Defaults {
    static let iconAlertSize = CGSize(width: 340, height: 172)
}
