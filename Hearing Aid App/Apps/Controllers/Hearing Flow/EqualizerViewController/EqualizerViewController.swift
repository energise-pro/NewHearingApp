import UIKit

final class EqualizerViewController: PMBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2EqualizerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Equalizer".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, EqualizerTableViewCell.self, SliderTableViewCell.self, SCentButtnTablViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Equalizer".localized(), buttonTypes: [.switchButton], switchState: AudioKitService.shared.isEqualizedEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        let equalizerChartCellModel = EqualizerTableViewCellModel(dataSource: EqualizerBands.allCases.compactMap { $0.value })
        let equalizerChartCellConfig = EqualizerTableViewCellConfig(item: equalizerChartCellModel, height: 250.0)
        
        dataSource = [statusCellConfig, equalizerChartCellConfig]
        
        EqualizerBands.allCases.enumerated().forEach { index, band in
            let cellModel = SliderTableViewCellModel(title: band.hzTitle, sliderValue: Float(band.value), minSliderValue: Float(EqualizerBands.minValue), maxSliderValue: Float(EqualizerBands.maxValue), topInset: index == 0 ? 20.0 : 0.0, delegate: self)
            let cellConfig = SliderTableViewCellConfig(item: cellModel)
            dataSource.append(cellConfig)
        }
        
        let resetCellModel = SCentButtnTablViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(systemName: "trash.fill")!, delegate: self)
        let resetCellConfig = SCentButtnTablViewCellConfig(item: resetCellModel)
        
        dataSource.append(resetCellConfig)
        
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    private func updateChartCell() {
        guard let equalizerChartCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EqualizerTableViewCell else {
            return
        }
        equalizerChartCell.updateDataSource(on: EqualizerBands.allCases.compactMap { $0.value })
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfigService.shared.analytics.track(action: .v2EqualizerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EqualizerViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - SCentButtnTablViewCellDelegate
extension EqualizerViewController: SCentButtnTablViewCellDelegate {
    
    func didSelectButton(from cell: SCentButtnTablViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setEqualizer(false)
        AudioKitService.shared.equalizer?.reset()
        updateChartCell()
        configureDataSource()
        
        AppConfigService.shared.analytics.track(action: .v2EqualizerScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension EqualizerViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .switchButton:
            let newState = !AudioKitService.shared.isEqualizedEnabled
            AudioKitService.shared.setEqualizer(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
            AppConfigService.shared.analytics.track(action: .v2EqualizerScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.equalizer.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - SliderTableViewCellDelegate
extension EqualizerViewController: SliderTableViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: SliderTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SliderTableViewCellModel,
              let equalizerParameter = EqualizerBands.allCases[safe: indexRow - 2] else {
            return
        }
        equalizerParameter.setNew(Double(value))
        updateChartCell()
        let newCellModel = SliderTableViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = SliderTableViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: AnalyticsAction.delaySliderInterval, repeats: false) { _ in
            AppConfigService.shared.analytics.track(action: .v2EqualizerScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(AnalyticsAction.equalizer.rawValue)"])
        }
    }
}
