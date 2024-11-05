import UIKit

protocol ErdSetupViewControllerDelegate: AnyObject {
    func didUpdateSystemVolumeValue()
    func didChangeMicrophone()
}

final class ErdSetupViewController: PMUMainViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private weak var delegate: ErdSetupViewControllerDelegate?
    
    // MARK: - Init
    init(delegate: ErdSetupViewControllerDelegate?) {
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
        KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Pro Setup".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        let cellNibs: [UIViewCellNib.Type] = [NSimplSementTablViewCell.self, SettingTableViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let avaliableMicrophones = SAudioKitServicesAp.shared.connectedHeadphones ? MicroFineType.allCases : [.bottom, .front, .back]
        let segmentCellModel = NSimplSementTablViewCellModel(mainTitle: "Active microphone".localized(), titles: avaliableMicrophones.compactMap { $0.title }, selectedIndex: MicroFineType.selectedMicrophone.rawValue, delegate: self)
        let segmentCellConfig = NSimplSementTablViewCellConfig(item: segmentCellModel)
        
        let musicModeCellModel = SettingTableViewCellModel(title: "Music mode".localized(), buttonTypes: [.info, .switchButton], switchState: SAudioKitServicesAp.shared.isMusicModeEnabled, delegate: self)
        let musicCellConfig = SettingTableViewCellConfig(item: musicModeCellModel)
        
        let systemVolumeCellModel = SettingTableViewCellModel(title: "Use system volume".localized(), buttonTypes: [.info, .switchButton], switchState: SAudioKitServicesAp.shared.isUseSystemVolume, delegate: self)
        let systemVolumeCellConfig = SettingTableViewCellConfig(item: systemVolumeCellModel)
        
        let clearVoiceCellModel = SettingTableViewCellModel(title: "Clear voice".localized(), buttonTypes: [.info, .switchButton], switchState: SAudioKitServicesAp.shared.isClearVoice, delegate: self)
        let clearVoiceCellConfig = SettingTableViewCellConfig(item: clearVoiceCellModel)
        
        let voiceChangerCellModel = SettingTableViewCellModel(title: "Voice changer".localized(), buttonTypes: [.rightButton], topInset: 70.0, delegate: self)
        let voiceChangerCellConfig = SettingTableViewCellConfig(item: voiceChangerCellModel)
        
        let compressorCellModel = SettingTableViewCellModel(title: "Compressor".localized(), buttonTypes: [.rightButton], delegate: self)
        let compressorCellConfig = SettingTableViewCellConfig(item: compressorCellModel)
        
        let limiterCellModel = SettingTableViewCellModel(title: "Limiter".localized(), buttonTypes: [.rightButton], delegate: self)
        let limiterCellConfig = SettingTableViewCellConfig(item: limiterCellModel)
        
        let equalizerCellModel = SettingTableViewCellModel(title: "Equalizer".localized(), buttonTypes: [.rightButton], delegate: self)
        let equalizerCellConfig = SettingTableViewCellConfig(item: equalizerCellModel)
        
        let resetCellModel = VCentereButnTableViewCellModel(buttonTitle: "Reset setup".localized(), buttonImage: UIImage(systemName: "trash.fill")!, delegate: self)
        let resetCellConfig = VCentereButnTableViewCellConfig(item: resetCellModel)
        
        dataSource = [segmentCellConfig, musicCellConfig, systemVolumeCellConfig, clearVoiceCellConfig, voiceChangerCellConfig, compressorCellConfig, limiterCellConfig, equalizerCellConfig, resetCellConfig]
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ErdSetupViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - NSimplSementTablViewCellDelegate
extension ErdSetupViewController: NSimplSementTablViewCellDelegate {
    
    func didSelectSegment(with index: Int, from cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              var cellModel = dataSource[safe: indexPath.row]?.getItem() as? NSimplSementTablViewCellModel else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.changeMicrophone(on: MicroFineType(rawValue: index)!)
        
        cellModel.selectedIndex = MicroFineType.selectedMicrophone.rawValue
        let cellConfig = NSimplSementTablViewCellConfig(item: cellModel)
        dataSource[indexPath.row] = cellConfig
        delegate?.didChangeMicrophone()
        
        let selectedMicrophoneString = String(describing: MicroFineType.selectedMicrophone)
        KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.changeMicrophone.rawValue)_\(selectedMicrophoneString)"])
    }
}

// MARK: - VCentereButnTableViewCellDelegate
extension ErdSetupViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.changeMicrophone(on: MicroFineType.defaultMicrophone)
        SAudioKitServicesAp.shared.setMusicMode(false)
        SAudioKitServicesAp.shared.setUseSystemVolume(false)
        SAudioKitServicesAp.shared.setClearVoice(false)
        configureDataSource()
        delegate?.didUpdateSystemVolumeValue()
        delegate?.didChangeMicrophone()
        
        KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension ErdSetupViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row,
              let cellModel = dataSource[indexRow].getItem() as? SettingTableViewCellModel else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1: // Music mode
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "If you set this option, system will mixes audio from this app with audio playing in background apps, such as the Music app.\nFor example, you want to listen a music or audio book over headphones, and at the same time hear sounds around you very well.\nIf this option OFF system reduces the volume of other audio apps to make the audio of this app more prominent.".localized())
                
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.musicMode.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !SAudioKitServicesAp.shared.isMusicModeEnabled
                SAudioKitServicesAp.shared.setMusicMode(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.musicMode.rawValue)_\(stringState)"])
            default:
                break
            }
        case 2: // System volume
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "Increase Volume of Hearing Aid together with the device system volume".localized())
                
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.systemVolume.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !SAudioKitServicesAp.shared.isUseSystemVolume
                SAudioKitServicesAp.shared.setUseSystemVolume(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                delegate?.didUpdateSystemVolumeValue()
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.systemVolume.rawValue)_\(stringState)"])
            default:
                break
            }
        case 3: // Clear Voice
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "AI helps to pick a voice out from the background noise and other sounds".localized())
                
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.clearVoice.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !SAudioKitServicesAp.shared.isClearVoice
                SAudioKitServicesAp.shared.setClearVoice(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.clearVoice.rawValue)_\(stringState)"])
            default:
                break
            }
        case 4:
            AppsNavManager.shared.pushRVoicChangeJViewController()
            KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.voiceChanger.rawValue])
        case 5: // Compressor
            AppsNavManager.shared.pushKCompresViewController()
            KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.compressor.rawValue])
        case 6: // Limiter
            AppsNavManager.shared.pushYLimitApViewController()
            KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.limiter.rawValue])
        case 7: // Equalizer
            AppsNavManager.shared.pushUEqualizeApViewController()
            KAppConfigServic.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.equalizer.rawValue])
        default:
            break
        }
    }
}
