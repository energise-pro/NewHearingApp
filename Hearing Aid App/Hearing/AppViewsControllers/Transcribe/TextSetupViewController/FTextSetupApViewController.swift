import UIKit

protocol FTextSetupApViewControllerDelegate: AnyObject {
    func didUpdateTextParameters()
    func didChangeLocale()
}

extension FTextSetupApViewControllerDelegate {
    
    func didChangeLocale() { }
}

final class FTextSetupApViewController: PMUMainViewController {
    
    enum ScreenType {
        case transcribe
        case translate
        
        var analyticAction: GAppAnalyticActions {
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
    
    private weak var delegate: FTextSetupApViewControllerDelegate?
    private var screenType: ScreenType
    private var sliderTimer: Timer?
    
    // MARK: - Init
    init(screenType: ScreenType, delegate: FTextSetupApViewControllerDelegate?) {
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
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        
        view.backgroundColor = UIColor.appColor(.Purple10)
        
        let cellNibs: [UIViewCellNib.Type] = [HTexParamTableViewCell.self, SettingTableViewCell.self, NewSettingWithSubtitleTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let textCellModel = HTexParamTableViewCellModel(delegate: self)
        let textCellConfig = HTexParamTableViewCellConfig(item: textCellModel)
        
        let currentLocale = CTranscribServicesAp.shared.localizedSelectedLocale.capitalized
        let localeCellTitle = NSAttributedString(string: "Your language", attributes: [
            .foregroundColor: UIColor.appColor(.Purple100)!,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ])
        let localeCellModel = NewSettingWithSubtitleTableViewCellModel(attributedTitle: localeCellTitle, subtitle: currentLocale, buttonTypes: [.rightButton], topInset: 10, delegate: self)
        let localeCellConfig = NewSettingWithSubtitleTableViewCellConfig(item: localeCellModel, height: 87)
        
        let buttonTypes: [SettingTableViewButtonType] = screenType == .translate ? [.switchButton, .info] : [.switchButton]
        let clearCellModel = SettingTableViewCellModel(title: "Shake to delete transcript".localized(), buttonTypes: buttonTypes, switchState: CTranscribServicesAp.shared.isShakeToClear, delegate: self)
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
extension FTextSetupApViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - HTexParamTableViewCellDelegate
extension FTextSetupApViewController: HTexParamTableViewCellDelegate {
    
    func didChangeValue(value: Int, for parameter: GTranscribTextParam, from cell: HTexParamTableViewCell) {
        parameter.setNew(value)
        delegate?.didUpdateTextParameters()
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            KAppConfigServic.shared.analytics.track(action: self.screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(parameter.rawValue)"])
        }
    }
}

// MARK: - SettingTableViewCellDelegate
extension FTextSetupApViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1 where screenType == .transcribe: // Locale
            AppsNavManager.shared.pushJLocaleListApViewController(with: screenType == .transcribe ? .transcribe : .translateFrom, with: self)
            KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeLanguage.rawValue])
        case 1 where screenType == .translate, 2 where screenType == .transcribe: // Shake
            switch type {
            case .switchButton:
                let newState = !CTranscribServicesAp.shared.isShakeToClear
                CTranscribServicesAp.shared.setShakeToClear(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.shakeClearText.rawValue)_\(stringState)"])
            case .info:
                presentAlertPM(title: "Shake to delete transcript".localized(), message: "Shake your device to delete the entire transcript automatically".localized())
//                KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.limiter.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - NewSettingWithSubtitleTableViewCellDelegate
extension FTextSetupApViewController: NewSettingWithSubtitleTableViewCellDelegate {
    
    func didSelectButton(with type: NewSettingWithSubtitleTableViewButtonType, from cell: NewSettingWithSubtitleTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1 where screenType == .transcribe: // Locale
            AppsNavManager.shared.pushJLocaleListApViewController(with: screenType == .transcribe ? .transcribe : .translateFrom, with: self)
            KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeLanguage.rawValue])

        default:
            break
        }
    }
}

// MARK: - JLocaleListApViewControllerDelegate
extension FTextSetupApViewController: JLocaleListApViewControllerDelegate {
    
    func didChangeLocale() {
        delegate?.didChangeLocale()
        configureDataSource()
    }
}
