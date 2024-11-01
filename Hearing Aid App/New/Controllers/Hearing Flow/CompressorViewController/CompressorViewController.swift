import UIKit

final class CompressorViewController: PMBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Compressor".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, SliderTableViewCell.self, CenterButtonTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Compressor status".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isCompressorEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        CompressorParameter.allCases.enumerated().forEach { index, parameter in
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
        
        AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CompressorViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension CompressorViewController: CenterButtonTableViewCellDelegate {
    
    func didSelectButton(from cell: CenterButtonTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setCompressor(true)
        CompressorParameter.allCases.forEach { $0.setNew($0.defaultValue) }
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension CompressorViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info:
            presentAlertPM(title: "Info".localized(), message: "The compressor allows you to set up sound more punchy. Compressors reduce the difference between the loudest and quietest parts of the volume".localized())
            
            AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.compressor.rawValue)_\(AnalyticsAction.info.rawValue)"])
        case .switchButton:
            let newState = !AudioKitService.shared.isCompressorEnabled
            AudioKitService.shared.setCompressor(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
            AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.compressor.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - SliderTableViewCellDelegate
extension CompressorViewController: SliderTableViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: SliderTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SliderTableViewCellModel,
              let compressorParameter = CompressorParameter.allCases[safe: indexRow - 1] else {
            return
        }
        AudioKitService.shared.changeCompressorValue(on: Double(value), for: compressorParameter)
        let newCellModel = SliderTableViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = SliderTableViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: AnalyticsAction.delaySliderInterval, repeats: false) { _ in
            AppConfigService.shared.analytics.track(action: .v2CompressorScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(compressorParameter.rawValue)"])
        }
    }
}
