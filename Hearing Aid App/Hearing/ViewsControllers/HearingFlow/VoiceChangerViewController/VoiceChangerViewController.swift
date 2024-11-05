import UIKit

final class RVoicChangeJViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Voice changer".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, GSlideBTablViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Voice changer status".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isVoiceChangerEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        PdShParam.allCases.enumerated().forEach { index, parameter in
            let cellModel = GSlideBTablViewCellModel(title: parameter.title.capitalizingFirstLetter(), sliderValue: Float(parameter.value), minSliderValue: Float(parameter.minValue), maxSliderValue: Float(parameter.maxValue), topInset: index == 0 ? 70.0 : 0.0, delegate: self)
            let cellConfig = GSlideBTablViewCellConfig(item: cellModel)
            dataSource.append(cellConfig)
        }
        
        let resetCellModel = VCentereButnTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(systemName: "trash.fill")!, delegate: self)
        let resetCellConfig = VCentereButnTableViewCellConfig(item: resetCellModel)
        
        dataSource.append(resetCellConfig)
        
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RVoicChangeJViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - VCentereButnTableViewCellDelegate
extension RVoicChangeJViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setVoiceChanger(false)
        PdShParam.allCases.forEach { $0.setNew($0.defaultValue) }
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension RVoicChangeJViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info:
            presentAlertPM(title: "Info".localized(), message: "The voice changer allows you to change voice parameters. With the voice changer, you can set the pitch to higher or lower".localized())
            
            AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.voiceChanger.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
        case .switchButton:
            let newState = !AudioKitService.shared.isVoiceChangerEnabled
            AudioKitService.shared.setVoiceChanger(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.voiceChanger.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - GSlideBTablViewCellDelegate
extension RVoicChangeJViewController: GSlideBTablViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: GSlideBTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? GSlideBTablViewCellModel,
              let pitchParameter = PdShParam.allCases[safe: indexRow - 1] else {
            return
        }
        AudioKitService.shared.changePitchShifterValue(on: Double(value), for: pitchParameter)
        let newCellModel = GSlideBTablViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = GSlideBTablViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            AppConfiguration.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(pitchParameter.rawValue)"])
        }
    }
}
