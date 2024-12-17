import UIKit

final class YLimitApViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Limiter".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.appColor(.Red100)!
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, GSlideBTablViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(
            attributedTitle: NSAttributedString(string: "Limiter status".localized(), attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.appColor(.Purple100)!]),
            buttonTypes: [.switchButton],
            switchState: SAudioKitServicesAp.shared.isLimiterEnabled,
            cellHeight: 82,
            delegate: self
        )
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        dataSource = [statusCellConfig]
        
        VPLirParameter.allCases.enumerated().forEach { index, parameter in
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
    
    private func presentWarningAlert() {
        let yesAction = UIAlertAction(title: "Yes!".localized(), style: .destructive) { [weak self] _ in
            SAudioKitServicesAp.shared.setLimiter(false)
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
        let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: SAudioKitServicesAp.shared.isLimiterEnabled, delegate: self)
        dataSource[0] = SettingTableViewCellConfig(item: newCellModel)
    }

    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension YLimitApViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension YLimitApViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.setLimiter(true)
        VPLirParameter.allCases.forEach { $0.setNew($0.defaultValue) }
        SAudioKitServicesAp.shared.resetLimiterValues()
        configureDataSource()
        
        KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension YLimitApViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info: // Limiter status
            presentAlertPM(title: "Limiter status".localized(), message: "Peak limiter allows you to bring up the level without allowing the peaks to clip. It limits high-volume spikes which can sound disgusting".localized())
            
            KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.limiter.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
        case .switchButton:
            let newState = !SAudioKitServicesAp.shared.isLimiterEnabled
            newState ? SAudioKitServicesAp.shared.setLimiter(newState) : presentWarningAlert()
            updateSettingsCell()
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.limiter.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - GSlideBTablViewCellDelegate
extension YLimitApViewController: GSlideBTablViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: GSlideBTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? GSlideBTablViewCellModel,
              let VPLirParameter = VPLirParameter.allCases[safe: indexRow - 1] else {
            return
        }
        SAudioKitServicesAp.shared.changeLimiterValue(on: Double(value), for: VPLirParameter)
        let newCellModel = GSlideBTablViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = GSlideBTablViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            KAppConfigServic.shared.analytics.track(action: .v2LimiterScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(VPLirParameter.rawValue)"])
        }
    }
}
