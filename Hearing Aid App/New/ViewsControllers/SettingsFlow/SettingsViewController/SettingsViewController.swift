import UIKit

private struct Defaults {
    static let iconAlertSize = CGSize(width: 340, height: 172)
}

final class SettingsViewController: PMBaseViewController {

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
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ThemeService.shared.activeColor as Any, .font: UIFont.systemFont(ofSize: 28.0, weight: .bold) as Any]
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Settings".localized()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ThemeService.shared.activeColor as Any, .font: UIFont.systemFont(ofSize: 28.0, weight: .bold) as Any]
        
        tableView.contentInset = UIEdgeInsets(top: 25.0, left: .zero, bottom: .zero, right: .zero)
        
        let cellNibs: [UIViewCellNib.Type] = [ThemeTableViewCell.self, SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let themeCellModel = ThemeTableViewCellModel(title: "Color Theme".localized(), selectedTheme: ThemeService.shared.currentColorType, themes: [.blue, .orange, .red, .green, .purpule], delegate: self)
        let themeCellConfig = ThemeTableViewCellConfig(item: themeCellModel)
        
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
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension SettingsViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1: // Premium
            NavigationManager.shared.presentPaywallViewController(with: .openFromSetting)
        case 2: // Restore
            NativeLoaderView.showLoader(at: NavigationManager.shared.topViewController?.view ?? view, animated: true)
            InAppPurchasesService.shared.restorePurchases { [weak self] isSuccess in
                guard let self = self else {
                    return
                }
                NativeLoaderView.hideLoader(for: NavigationManager.shared.topViewController?.view ?? self.view, animated: true)
                let title = isSuccess ? "Purchases successfully restored".localized() : "Oops".localized()
                let message = isSuccess ? "" : "You have not purchases yet".localized()
                isSuccess ? self.presentHidingAlert(title: title, message: message) : self.presentAlertPM(title: title, message: message)
            }
            
            AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.restore.rawValue])
        case 3: // App icon
            NavigationManager.shared.presentZAppIconViewController()
            
            AppConfiguration.shared.analytics.track(.v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeAppIcon.rawValue])
        case 4: // Haptic
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "Disable or Enable vibrations when you press UI buttons".localized())
                
                AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.haptic.rawValue)_\(AnalyticsAction.info.rawValue)"])
            case .switchButton:
                let newState = !TapticEngine.isOn
                TapticEngine.isOn = newState
                //ThemeSettingsRow.TapticOption.setValue(newState)

                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, topInset: cellModel.topInset, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)

                let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
                AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.haptic.rawValue)_\(stringState)"])
            default:
                break
            }
        case 5: // FAQ
            NavigationManager.shared.presentSafariViewController(with: Constants.URLs.faqURL)
            
            AppConfiguration.shared.analytics.track(.v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.faq.rawValue])
        case 6: // Website
            NavigationManager.shared.presentSafariViewController(with: Constants.URLs.ourWebSiteURL)
            
            AppConfiguration.shared.analytics.track(.v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.ourWebsite.rawValue])
        case 7: // More
            NavigationManager.shared.presentMoreViewController()
            
            AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.more.rawValue])
        case 8: // Support
            NavigationManager.shared.presentSupportViewController()
            
            AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.support.rawValue])
        default:
            break
        }
    }
}

// MARK:  ThemeTableViewCellDelegate
extension SettingsViewController: ThemeTableViewCellDelegate {
    
    func didSelectTheme(with type: ColorType, from cell: ThemeTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? ThemeTableViewCellModel else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        ThemeService.shared.setColorType(type)
        AppConfiguration.shared.settings.presentAppRatingAlert()
        
        let newCellModel = ThemeTableViewCellModel(title: cellModel.title, selectedTheme: ThemeService.shared.currentColorType, themes: cellModel.themes, delegate: self)
        dataSource[indexRow] = ThemeTableViewCellConfig(item: newCellModel)
        
        AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.select.rawValue)_\(type.analyticAction.rawValue)"])
    }
}
