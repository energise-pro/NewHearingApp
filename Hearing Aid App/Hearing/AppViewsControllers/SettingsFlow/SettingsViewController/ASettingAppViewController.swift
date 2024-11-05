import UIKit

final class ASettingAppViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AThemeServicesAp.shared.activeColor as Any, .font: UIFont.systemFont(ofSize: 28.0, weight: .bold) as Any]
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Settings".localized()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AThemeServicesAp.shared.activeColor as Any, .font: UIFont.systemFont(ofSize: 28.0, weight: .bold) as Any]
        
        tableView.contentInset = UIEdgeInsets(top: 25.0, left: .zero, bottom: .zero, right: .zero)
        
        let cellNibs: [UIViewCellNib.Type] = [UThemNTablViewCell.self, SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let themeCellModel = UThemNTablViewCellModel(title: "Color Theme".localized(), selectedTheme: AThemeServicesAp.shared.currentColorType, themes: [.blue, .orange, .red, .green, .purpule], delegate: self)
        let themeCellConfig = UThemNTablViewCellConfig(item: themeCellModel)
        
        let premiumCellModel = SettingTableViewCellModel(title: "Unlock Premium".localized(), buttonTypes: [.rightButton], delegate: self)
        let premiumCellConfig = SettingTableViewCellConfig(item: premiumCellModel)
        
        let restoreCellModel = SettingTableViewCellModel(title: "Restore Purchase".localized(), buttonTypes: [.rightButton], delegate: self)
        let restoreCellConfig = SettingTableViewCellConfig(item: restoreCellModel)
        
        let changeAppIconCellModel = SettingTableViewCellModel(title: "Change App Icon".localized(), buttonTypes: [.rightButton], delegate: self)
        let changeAppIconCellConfig = SettingTableViewCellConfig(item: changeAppIconCellModel)
        
        let hapticCellModel = SettingTableViewCellModel(title: "Use Haptic Feedback".localized(), buttonTypes: [.info, .switchButton], switchState: TapticEngine.isOn, delegate: self)
        let hapticCellConfig = SettingTableViewCellConfig(item: hapticCellModel)
        
        let faqCellModel = SettingTableViewCellModel(title: "FAQ".localized(), buttonTypes: [.rightButton], delegate: self)
        let faqCellConfig = SettingTableViewCellConfig(item: faqCellModel)
        
        let websiteCellModel = SettingTableViewCellModel(title: "Our website".localized(), buttonTypes: [.rightButton], delegate: self)
        let websiteCellConfig = SettingTableViewCellConfig(item: websiteCellModel)
        
        let moreCellModel = SettingTableViewCellModel(title: "More".localized(), buttonTypes: [.rightButton], delegate: self)
        let moreCellConfig = SettingTableViewCellConfig(item: moreCellModel)
        
        let supportCellModel = SettingTableViewCellModel(title: "Support & Contact Us".localized(), buttonTypes: [.rightButton], delegate: self)
        let supportCellConfig = SettingTableViewCellConfig(item: supportCellModel)
        
        dataSource = [themeCellConfig, premiumCellConfig, restoreCellConfig, changeAppIconCellConfig, hapticCellConfig, faqCellConfig, websiteCellConfig, moreCellConfig, supportCellConfig]
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ASettingAppViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfig: CellConfigurator = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfig.identifier, for: indexPath)
        cellConfig.configure(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].height ?? UITableView.automaticDimension
    }
}

// MARK: - SettingTableViewCellDelegate
extension ASettingAppViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1: // Premium
            AppsNavManager.shared.presentPaywallViewController(with: .openFromSetting)
        case 2: // Restore
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
        case 3: // App icon
            AppsNavManager.shared.presentZAppIconViewController()
            
            KAppConfigServic.shared.analytics.track(.v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeAppIcon.rawValue])
        case 4: // Haptic
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "Disable or Enable vibrations when you press UI buttons".localized())
                
                KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.haptic.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !TapticEngine.isOn
                TapticEngine.isOn = newState
                //ThemeSettingsRow.TapticOption.setValue(newState)

                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, topInset: cellModel.topInset, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)

                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.haptic.rawValue)_\(stringState)"])
            default:
                break
            }
        case 5: // FAQ
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.faqURL)
            
            KAppConfigServic.shared.analytics.track(.v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.faq.rawValue])
        case 6: // Website
            AppsNavManager.shared.presentSafariViewController(with: CAppConstants.URLs.ourWebSiteURL)
            
            KAppConfigServic.shared.analytics.track(.v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.ourWebsite.rawValue])
        case 7: // More
            AppsNavManager.shared.presentOMoreApViewController()
            
            KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.more.rawValue])
        case 8: // Support
            AppsNavManager.shared.presentSupportViewController()
            
            KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.support.rawValue])
        default:
            break
        }
    }
}

// MARK:  UThemNTablViewCellDelegate
extension ASettingAppViewController: UThemNTablViewCellDelegate {
    
    func didSelectTheme(with type: ColorType, from cell: UThemNTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? UThemNTablViewCellModel else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        AThemeServicesAp.shared.setColorType(type)
        KAppConfigServic.shared.settings.presentAppRatingAlert()
        
        let newCellModel = UThemNTablViewCellModel(title: cellModel.title, selectedTheme: AThemeServicesAp.shared.currentColorType, themes: cellModel.themes, delegate: self)
        dataSource[indexRow] = UThemNTablViewCellConfig(item: newCellModel)
        
        KAppConfigServic.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.select.rawValue)_\(type.analyticAction.rawValue)"])
    }
}

private struct Defaults {
    static let iconAlertSize = CGSize(width: 340, height: 172)
}
