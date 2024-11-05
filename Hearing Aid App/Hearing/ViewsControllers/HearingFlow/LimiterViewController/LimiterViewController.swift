import UIKit

final class LimiterViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Limiter".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, SliderTableViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(title: "Limiter status".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isLimiterEnabled, delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        VPLirParameter.allCases.enumerated().forEach { index, parameter in
            let cellModel = SliderTableViewCellModel(title: parameter.title.capitalizingFirstLetter(), sliderValue: Float(parameter.value), minSliderValue: Float(parameter.minValue), maxSliderValue: Float(parameter.maxValue), topInset: index == 0 ? 70.0 : 0.0, delegate: self)
            let cellConfig = SliderTableViewCellConfig(item: cellModel)
            dataSource.append(cellConfig)
        }
        
        let resetCellModel = VCentereButnTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(systemName: "trash.fill")!, delegate: self)
        let resetCellConfig = VCentereButnTableViewCellConfig(item: resetCellModel)
        
        dataSource.append(resetCellConfig)
        
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    private func presentWarningAlert() {
        let yesAction = UIAlertAction(title: "Yes!".localized(), style: .destructive) { [weak self] _ in
            AudioKitService.shared.setLimiter(false)
            self?.updateSettingsCell()
        }
        let noAction = UIAlertAction(title: "No".localized(), style: .default) { [weak self] _ in
            self?.configureDataSource()
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.presentAlertPM(title: "Disable Limiter?".localized(), message: "Should I disable peak limiter?".localized(), actions: [yesAction, noAction])
        }
        presentAlertPM(title: "Info".localized(), message: "I don't recommend you disable 'Peak Limiter' since it limits high-volume spikes which can sound disgusting. However it's safe to change any parameters.".localized() + "\n" + "Play around you can always reset to initial state :)".localized(), actions: [okAction])
    }
    
    private func updateSettingsCell() {
        guard let cellModel = dataSource[0].getItem() as? SettingTableViewCellModel else {
            return
        }
        let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: AudioKitService.shared.isLimiterEnabled, delegate: self)
        dataSource[0] = SettingTableViewCellConfig(item: newCellModel)
    }

    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LimiterViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension LimiterViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.setLimiter(true)
        VPLirParameter.allCases.forEach { $0.setNew($0.defaultValue) }
        configureDataSource()
        
        AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension LimiterViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info:
            presentAlertPM(title: "Info".localized(), message: "Peak limiter allows you to bring up the level without allowing the peaks to clip. It limits high-volume spikes which can sound disgusting".localized())
            
            AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.limiter.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
        case .switchButton:
            let newState = !AudioKitService.shared.isLimiterEnabled
            newState ? AudioKitService.shared.setLimiter(newState) : presentWarningAlert()
            updateSettingsCell()
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.limiter.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - SliderTableViewCellDelegate
extension LimiterViewController: SliderTableViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: SliderTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SliderTableViewCellModel,
              let VPLirParameter = VPLirParameter.allCases[safe: indexRow - 1] else {
            return
        }
        AudioKitService.shared.changeLimiterValue(on: Double(value), for: VPLirParameter)
        let newCellModel = SliderTableViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = SliderTableViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            AppConfiguration.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(VPLirParameter.rawValue)"])
        }
    }
}
