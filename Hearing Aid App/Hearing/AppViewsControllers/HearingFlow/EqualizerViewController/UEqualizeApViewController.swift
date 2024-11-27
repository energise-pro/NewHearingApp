import UIKit

final class UEqualizeApViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var sliderTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        
        KAppConfigServic.shared.analytics.track(action: .v2EqualizerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Equalizer".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.appColor(.Red100)!
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, JEqlizeTableViewCell.self, GSlideBTablViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        var dataSource: [CellConfigurator] = []
        
        let statusCellModel = SettingTableViewCellModel(attributedTitle: NSAttributedString(string: "Equalizer".localized(), attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.appColor(.Purple100)!]),
                                                        buttonTypes: [.switchButton],
                                                        switchState: SAudioKitServicesAp.shared.isEqualizedEnabled,
                                                        delegate: self)
        let statusCellConfig = SettingTableViewCellConfig(item: statusCellModel)
        
        let equalizerChartCellModel = JEqlizeTableViewCellModel(dataSource: EqualizerBands.allCases.compactMap { $0.value })
        let equalizerChartCellConfig = JEqlizeTableViewCellConfig(item: equalizerChartCellModel, height: 250.0)
        
        dataSource = [statusCellConfig, equalizerChartCellConfig]
        
        EqualizerBands.allCases.enumerated().forEach { index, band in
            let cellModel = GSlideBTablViewCellModel(title: band.hzTitle, sliderValue: Float(band.value), minSliderValue: Float(EqualizerBands.minValue), maxSliderValue: Float(EqualizerBands.maxValue), topInset: index == 0 ? 20.0 : 0.0, delegate: self)
            let cellConfig = GSlideBTablViewCellConfig(item: cellModel)
            dataSource.append(cellConfig)
        }
        
        let resetCellModel = VCentereButnTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(named: "trashIcon")!, delegate: self)
        let resetCellConfig = VCentereButnTableViewCellConfig(item: resetCellModel)
        
        dataSource.append(resetCellConfig)
        
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    private func updateChartCell() {
        guard let equalizerChartCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? JEqlizeTableViewCell else {
            return
        }
        equalizerChartCell.updateDataSource(on: EqualizerBands.allCases.compactMap { $0.value })
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2EqualizerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension UEqualizeApViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension UEqualizeApViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.setEqualizer(false)
        SAudioKitServicesAp.shared.equalizer?.reset()
        updateChartCell()
        configureDataSource()
        
        KAppConfigServic.shared.analytics.track(action: .v2EqualizerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension UEqualizeApViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .switchButton:
            let newState = !SAudioKitServicesAp.shared.isEqualizedEnabled
            SAudioKitServicesAp.shared.setEqualizer(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            KAppConfigServic.shared.analytics.track(action: .v2EqualizerScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.equalizer.rawValue)_\(stringState)"])
        default:
            break
        }
    }
}

// MARK: - GSlideBTablViewCellDelegate
extension UEqualizeApViewController: GSlideBTablViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: GSlideBTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? GSlideBTablViewCellModel,
              let equalizerParameter = EqualizerBands.allCases[safe: indexRow - 2] else {
            return
        }
        equalizerParameter.setNew(Double(value))
        updateChartCell()
        let newCellModel = GSlideBTablViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = GSlideBTablViewCellConfig(item: newCellModel)
        
        sliderTimer?.invalidate()
        sliderTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            KAppConfigServic.shared.analytics.track(action: .v2EqualizerScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.change.rawValue)_\(GAppAnalyticActions.equalizer.rawValue)"])
        }
    }
}
