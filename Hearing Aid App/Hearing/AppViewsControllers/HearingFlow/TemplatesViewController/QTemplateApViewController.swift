import UIKit

protocol QTemplateApViewControllerDelegate: AnyObject {
    func didChangeTemplatesValue()
}

final class QTemplateApViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    weak var delegate: QTemplateApViewControllerDelegate?
    
    private var volumeTimer: Timer?
    
    // MARK: - Init
    init(delegate: QTemplateApViewControllerDelegate?) {
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
        
//        KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
//    override func didChangeTheme() {
//        super.didChangeTheme()
//        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
//    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Templates".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, GSlideBTablViewCell.self, GCenterPickrTablViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let templatesCellModel = SettingTableViewCellModel(
            attributedTitle: NSAttributedString(string: "Templates".localized(), attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.appColor(.Purple100)!]),
            buttonTypes: [.info, .switchButton],
            switchState: SAudioKitServicesAp.shared.isTemplatesEnabled,
            cellHeight: 82,
            delegate: self
        )
        let templatesCellConfig = SettingTableViewCellConfig(item: templatesCellModel)
        
        let volumeCellModel = GSlideBTablViewCellModel(title: "effect volume".localized().capitalizingFirstLetter(), sliderValue: Float(TemplatesParameter.dryWet.value), topInset: 70.0, delegate: self)
        let volumeCellConfig = GSlideBTablViewCellConfig(item: volumeCellModel)
        
        let pickerCellModel = GCenterPickrTablViewCellModel(dataSource: TemplatesType.allCases.compactMap { $0.title }, selectedValue: TemplatesType.selectedTemplate.title, delegate: self)
        let pickerCellConfig = GCenterPickrTablViewCellConfig(item: pickerCellModel, height: 250.0)
        
        let resetCellModel = VCentereButnTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(named: "trashIcon")!, delegate: self)
        let resetCellConfig = VCentereButnTableViewCellConfig(item: resetCellModel)
        
        dataSource = [templatesCellConfig, volumeCellConfig, pickerCellConfig, resetCellConfig]
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
//        KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension QTemplateApViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension QTemplateApViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.setTemplates(true)
        SAudioKitServicesAp.shared.changeTemplate(on: TemplatesType.defaultTemplate)
        SAudioKitServicesAp.shared.changeTemplatesVolume(on: TemplatesParameter.dryWet.defaultValue)
        configureDataSource()
        delegate?.didChangeTemplatesValue()
        
//        KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension QTemplateApViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .info: // Templates
            presentAlertPM(title: "Templates".localized(), message: "The Reverberation allows you to simulate the environment, space, room around you".localized())
            
//            KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.templates.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
        case .switchButton:
            let newState = !SAudioKitServicesAp.shared.isTemplatesEnabled
            SAudioKitServicesAp.shared.setTemplates(newState)
            let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
            dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
            delegate?.didChangeTemplatesValue()
            
            let actionState = newState ? GAppAnalyticActions.templatesOptionActivated : GAppAnalyticActions.templatesOptionDeactivated
            KAppConfigServic.shared.analytics.track(action: actionState, with: [
                "template_variant" : TemplatesType.selectedTemplate.title,
                "effect_volume" : TemplatesParameter.dryWet.value
            ])
        default:
            break
        }
    }
}

// MARK: - GSlideBTablViewCellDelegate
extension QTemplateApViewController: GSlideBTablViewCellDelegate {
    
    func didChangeSliderValue(on value: Float, from cell: GSlideBTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? GSlideBTablViewCellModel else {
            return
        }
        SAudioKitServicesAp.shared.changeTemplatesVolume(on: Double(value))
        let newCellModel = GSlideBTablViewCellModel(title: cellModel.title, sliderValue: value, minSliderValue: cellModel.minSliderValue, maxSliderValue: cellModel.maxSliderValue, topInset: cellModel.topInset, delegate: self)
        dataSource[indexRow] = GSlideBTablViewCellConfig(item: newCellModel)
        
        volumeTimer?.invalidate()
        volumeTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
//            KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeVolume.rawValue])
        }
    }
}

// MARK: - GCenterPickrTablViewCellDelegate
extension QTemplateApViewController: GCenterPickrTablViewCellDelegate {
    
    func didSelect(_ value: String?, from cell: GCenterPickrTablViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row, let cellModel = dataSource[indexRow].getItem() as? GCenterPickrTablViewCellModel, let selectedTemplate = value, let templatesType = TemplatesType.allCases.first(where: { $0.title == selectedTemplate }) else {
            return
        }
        SAudioKitServicesAp.shared.changeTemplate(on: templatesType)
        let newCellModel = GCenterPickrTablViewCellModel(dataSource: cellModel.dataSource, selectedValue: selectedTemplate, delegate: self)
        dataSource[indexRow] = GCenterPickrTablViewCellConfig(item: newCellModel)
        
//        KAppConfigServic.shared.analytics.track(action: .v2TemplatesScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeTemplate.rawValue])
    }
}
