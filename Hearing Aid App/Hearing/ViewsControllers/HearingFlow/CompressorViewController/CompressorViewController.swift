import UIKit

final class KCompresViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
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
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, GSlideBTablViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Compressor status".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isCompressorEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        CompressorParameter.allCases.enumerated().forEach { index, parameter in
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
        
        AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KCompresViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension KCompresViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setCompressor(true)
        CompressorParameter.allCases.forEach { $0.setNew($0.defaultValue) }
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension KCompresViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info:
            presentAlertPM(title: "Info".localized(), message: "The compressor allows you to set up sound more punchy. Compressors reduce the difference between the loudest and quietest parts of the volume".localized())
            
            AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.compressor.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
        case .switchButton:
            let newState = !AudioKitService.shared.isCompressorEnabled
            AudioKitService.shared.setCompressor(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.compressor.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - GSlideBTablViewCellDelegate
extension KCompresViewController: GSlideBTablViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: GSlideBTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? GSlideBTablViewCellModel,
              let compressorParameter = CompressorParameter.allCases[safe: indexRow - 1] else {
            return
        }
        AudioKitService.shared.changeCompressorValue(on: Double(value), for: compressorParameter)
        let newCellModel = GSlideBTablViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = GSlideBTablViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            AppConfiguration.shared.analytics.track(action: .v2CompressorScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(compressorParameter.rawValue)"])
        }
    }
}
