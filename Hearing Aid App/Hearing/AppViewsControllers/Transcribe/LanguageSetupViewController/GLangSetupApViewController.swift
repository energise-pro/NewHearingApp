import UIKit

protocol GLangSetupApViewControllerDelegate: AnyObject {
    func didChangeLocale()
}

final class GLangSetupApViewController: PMUMainViewController {

    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private weak var delegate: GLangSetupApViewControllerDelegate?
    
    // MARK: - Init
    init(delegate: GLangSetupApViewControllerDelegate?) {
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
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        
        view.backgroundColor = UIColor.appColor(.Purple10)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let offlineTranslateCellModel = SettingTableViewCellModel(title: "Offline translation".localized(), buttonTypes: [.switchButton], switchState: CTranscribServicesAp.shared.isOfflineTranslate, delegate: self)
        let offlineTranslateCellConfig = SettingTableViewCellConfig(item: offlineTranslateCellModel)
        
        let translateLanguageAttributedString = NSMutableAttributedString()
        translateLanguageAttributedString.append(NSAttributedString(string: "Translate language".localized() + ":", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]))
        translateLanguageAttributedString.append(NSAttributedString(string: "\n\(BTranslServicesNew.shared.localizedOutputLanguage.capitalized)", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]))
        let translateLanguageCellModel = SettingTableViewCellModel(title: nil, attributedTitle: translateLanguageAttributedString, buttonTypes: [.rightButton], cellHeight: 79, delegate: self)
        let translateLanguageCellConfig = SettingTableViewCellConfig(item: translateLanguageCellModel)
        
        let yourLanguageAttributedString = NSMutableAttributedString()
        yourLanguageAttributedString.append(NSAttributedString(string: "Your language".localized() + ":", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]))
        yourLanguageAttributedString.append(NSAttributedString(string: "\n\(BTranslServicesNew.shared.localizedInputLanguage.capitalized)", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]))
        let yourLanguageCellModel = SettingTableViewCellModel(title: nil, attributedTitle: yourLanguageAttributedString, buttonTypes: [.rightButton], cellHeight: 79, delegate: self)
        let yourLanguageCellConfig = SettingTableViewCellConfig(item: yourLanguageCellModel)
        
        dataSource = [offlineTranslateCellConfig, translateLanguageCellConfig, yourLanguageCellConfig]
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension GLangSetupApViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension GLangSetupApViewController: SettingTableViewCellDelegate {
    
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
                let newState = !CTranscribServicesAp.shared.isOfflineTranslate
                CTranscribServicesAp.shared.setOfflineTranslate(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.offlineTranslate.rawValue)_\(stringState)"])
            default:
                break
            }
        case 1: // Translate language
            AppsNavManager.shared.pushJLocaleListApViewController(with: .translateTo, with: self)
            KAppConfigServic.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.translateLanguage.rawValue])
        case 2: // Your language
            AppsNavManager.shared.pushJLocaleListApViewController(with: .translateFrom, with: self)
            KAppConfigServic.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.userLanguage.rawValue])
//        case 3: // Shake to clear
//            switch type {
//            case .switchButton:
//                let newState = !CTranscribServicesAp.shared.isShakeToClear
//                CTranscribServicesAp.shared.setShakeToClear(newState)
//                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
//                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
//                
//                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
//                KAppConfigServic.shared.analytics.track(action: .v2TranslateLanguageSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.shakeClearText.rawValue)_\(stringState)"])
//            default:
//                break
//            }
        default:
            break
        }
    }
}

// MARK: - JLocaleListApViewControllerDelegate
extension GLangSetupApViewController: JLocaleListApViewControllerDelegate {
    
    func didChangeLocale() {
        delegate?.didChangeLocale()
        configureDataSource()
    }
}
