import UIKit

final class VoiceChangerViewController: PMBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
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
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, SliderTableViewCell.self, CenterButtonTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Voice changer status".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isVoiceChangerEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        PitchShifterParameter.allCases.enumerated().forEach { index, parameter in
            let cellModel = SliderTableViewCellModel(title: parameter.title.capitalizingFirstLetter(), sliderValue: Float(parameter.value), minSliderValue: Float(parameter.minValue), maxSliderValue: Float(parameter.maxValue), topInset: index == 0 ? 70.0 : 0.0, delegate: self)
            let cellConfig = SliderTableViewCellConfig(item: cellModel)
            dataSource.append(cellConfig)
        }
        
        let resetCellModel = CenterButtonTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(systemName: "trash.fill")!, delegate: self)
        let resetCellConfig = CenterButtonTableViewCellConfig(item: resetCellModel)
        
        dataSource.append(resetCellConfig)
        
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension VoiceChangerViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - CenterButtonTableViewCellDelegate
extension VoiceChangerViewController: CenterButtonTableViewCellDelegate {
    
    func didSelectButton(from cell: CenterButtonTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setVoiceChanger(false)
        PitchShifterParameter.allCases.forEach { $0.setNew($0.defaultValue) }
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension VoiceChangerViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info:
            presentAlertPM(title: "Info".localized(), message: "The voice changer allows you to change voice parameters. With the voice changer, you can set the pitch to higher or lower".localized())
            
            AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.voiceChanger.rawValue)_\(AnalyticsAction.info.rawValue)"])
        case .switchButton:
            let newState = !AudioKitService.shared.isVoiceChangerEnabled
            AudioKitService.shared.setVoiceChanger(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
            AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.voiceChanger.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - SliderTableViewCellDelegate
extension VoiceChangerViewController: SliderTableViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: SliderTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SliderTableViewCellModel,
              let pitchParameter = PitchShifterParameter.allCases[safe: indexRow - 1] else {
            return
        }
        AudioKitService.shared.changePitchShifterValue(on: Double(value), for: pitchParameter)
        let newCellModel = SliderTableViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = SliderTableViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: AnalyticsAction.delaySliderInterval, repeats: false) { _ in
            AppConfigService.shared.analytics.track(action: .v2VoiceChangerScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(pitchParameter.rawValue)"])
        }
    }
}
