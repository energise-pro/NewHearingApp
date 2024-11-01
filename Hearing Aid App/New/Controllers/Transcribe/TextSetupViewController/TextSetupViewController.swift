import UIKit

protocol TextSetupViewControllerDelegate: AnyObject {
    func didUpdateTextParameters()
    func didChangeLocale()
}

extension TextSetupViewControllerDelegate {
    
    func didChangeLocale() { }
}

final class TextSetupViewController: PMBaseViewController {
    
    enum ScreenType {
        case transcribe
        case translate
        
        var analyticAction: AnalyticsAction {
            switch self {
            case .transcribe:
                return .v2TranscribeTextSetupScreen
            case .translate:
                return .v2TranslateTextSetupScreen
            }
        }
    }
    
    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private weak var delegate: TextSetupViewControllerDelegate?
    private var screenType: ScreenType
    private var sliderTimer: Timer?
    
    // MARK: - Init
    init(screenType: ScreenType, delegate: TextSetupViewControllerDelegate?) {
        self.screenType = screenType
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
        title = "Text setup".localized()
        
        view.backgroundColor = UIColor.appColor(.UnactiveButton_3)
        
        let cellNibs: [UIViewCellNib.Type] = [TextParametersTableViewCell.self, SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let textCellModel = TextParametersTableViewCellModel(delegate: self)
        let textCellConfig = TextParametersTableViewCellConfig(item: textCellModel)
        
        let currentLocale = TranscribeService.shared.localizedSelectedLocale.capitalized
        let localeCellModel = SettingTableViewCellModel(title: currentLocale, buttonTypes: [.rightButton], delegate: self)
        let localeCellConfig = SettingTableViewCellConfig(item: localeCellModel)
        
        let clearCellModel = SettingTableViewCellModel(title: "Shake to clear".localized(), buttonTypes: [.switchButton], switchState: TranscribeService.shared.isShakeToClear, delegate: self)
        let clearCellConfig = SettingTableViewCellConfig(item: clearCellModel)
        
        switch screenType {
        case .transcribe:
            dataSource = [textCellConfig, localeCellConfig, clearCellConfig]
        case .translate:
            dataSource = [textCellConfig, clearCellConfig]
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TextSetupViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - TextParametersTableViewCellDelegate
extension TextSetupViewController: TextParametersTableViewCellDelegate {
    
    func didChangeValue(value: Int, for parameter: TranscribeTextParameter, from cell: TextParametersTableViewCell) {
        parameter.setNew(value)
        delegate?.didUpdateTextParameters()
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: AnalyticsAction.delaySliderInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            AppConfiguration.shared.analytics.track(action: self.screenType.analyticAction, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(parameter.rawValue)"])
        }
    }
}

// MARK: - SettingTableViewCellDelegate
extension TextSetupViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1 where screenType == .transcribe: // Locale
            NavigationManager.shared.pushLocalesListViewController(with: screenType == .transcribe ? .transcribe : .translateFrom, with: self)
            AppConfiguration.shared.analytics.track(action: screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeLanguage.rawValue])
        case 1 where screenType == .translate, 2 where screenType == .transcribe: // Shake
            switch type {
            case .switchButton:
                let newState = !TranscribeService.shared.isShakeToClear
                TranscribeService.shared.setShakeToClear(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
                AppConfiguration.shared.analytics.track(action: screenType.analyticAction, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.shakeClearText.rawValue)_\(stringState)"])
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - LocalesListViewControllerDelegate
extension TextSetupViewController: LocalesListViewControllerDelegate {
    
    func didChangeLocale() {
        delegate?.didChangeLocale()
        configureDataSource()
    }
}
