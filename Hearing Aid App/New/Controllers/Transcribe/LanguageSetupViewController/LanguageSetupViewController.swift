import UIKit

protocol LanguageSetupViewControllerDelegate: AnyObject {
    func didChangeLocale()
}

final class LanguageSetupViewController: PMBaseViewController {

    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private weak var delegate: LanguageSetupViewControllerDelegate?
    
    // MARK: - Init
    init(delegate: LanguageSetupViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Language".localized()
        
        view.backgroundColor = UIColor.appColor(.UnactiveButton_3)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let offlineTranslateCellModel = SettingTableViewCellModel(title: "Offline translation".localized(), buttonTypes: [.switchButton], switchState: TranscribeService.shared.isOfflineTranslate, delegate: self)
        let offlineTranslateCellConfig = SettingTableViewCellConfig(item: offlineTranslateCellModel)
        
        let translateLanguageAttributedString = NSMutableAttributedString()
        translateLanguageAttributedString.append(NSAttributedString(string: "Translate language".localized() + ":", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]))
        translateLanguageAttributedString.append(NSAttributedString(string: "\n\(TranslateService.shared.localizedOutputLanguage.capitalized)", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]))
        let translateLanguageCellModel = SettingTableViewCellModel(title: nil, attributedTitle: translateLanguageAttributedString, buttonTypes: [.rightButton], delegate: self)
        let translateLanguageCellConfig = SettingTableViewCellConfig(item: translateLanguageCellModel)
        
        let yourLanguageAttributedString = NSMutableAttributedString()
        yourLanguageAttributedString.append(NSAttributedString(string: "Your language".localized() + ":", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]))
        yourLanguageAttributedString.append(NSAttributedString(string: "\n\(TranslateService.shared.localizedInputLanguage.capitalized)", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]))
        let yourLanguageCellModel = SettingTableViewCellModel(title: nil, attributedTitle: yourLanguageAttributedString, buttonTypes: [.rightButton], delegate: self)
        let yourLanguageCellConfig = SettingTableViewCellConfig(item: yourLanguageCellModel)
        
        let clearCellModel = SettingTableViewCellModel(title: "Shake to clear".localized(), buttonTypes: [.switchButton], switchState: TranscribeService.shared.isShakeToClear, delegate: self)
        let clearCellConfig = SettingTableViewCellConfig(item: clearCellModel)
        
        dataSource = [offlineTranslateCellConfig, translateLanguageCellConfig, yourLanguageCellConfig, clearCellConfig]
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LanguageSetupViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension LanguageSetupViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 0: // Offline translate
            switch type {
            case .switchButton:
                let newState = !TranscribeService.shared.isOfflineTranslate
                TranscribeService.shared.setOfflineTranslate(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
                AppConfigService.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.offlineTranslate.rawValue)_\(stringState)"])
            default:
                break
            }
        case 1: // Translate language
            NavigationManager.shared.pushLocalesListViewController(with: .translateTo, with: self)
            AppConfigService.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.translateLanguage.rawValue])
        case 2: // Your language
            NavigationManager.shared.pushLocalesListViewController(with: .translateFrom, with: self)
            AppConfigService.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.userLanguage.rawValue])
        case 3: // Shake to clear
            switch type {
            case .switchButton:
                let newState = !TranscribeService.shared.isShakeToClear
                TranscribeService.shared.setShakeToClear(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
                AppConfigService.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.shakeClearText.rawValue)_\(stringState)"])
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - LocalesListViewControllerDelegate
extension LanguageSetupViewController: LocalesListViewControllerDelegate {
    
    func didChangeLocale() {
        delegate?.didChangeLocale()
        configureDataSource()
    }
}
