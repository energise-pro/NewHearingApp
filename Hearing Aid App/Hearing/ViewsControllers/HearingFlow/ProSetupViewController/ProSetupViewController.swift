import UIKit

protocol ProSetupViewControllerDelegate: AnyObject {
    func didUpdateSystemVolumeValue()
    func didChangeMicrophone()
}

final class ProSetupViewController: PMUMainViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private weak var delegate: ProSetupViewControllerDelegate?
    
    // MARK: - Init
    init(delegate: ProSetupViewControllerDelegate?) {
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
        AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Pro Setup".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        let cellNibs: [UIViewCellNib.Type] = [SimpleSegmentTableViewCell.self, SettingTableViewCell.self, VCentereButnTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let avaliableMicrophones = AudioKitService.shared.connectedHeadphones ? MicroFineType.allCases : [.bottom, .front, .back]
        let segmentCellModel = SimpleSegmentTableViewCellModel(mainTitle: "Active microphone".localized(), titles: avaliableMicrophones.compactMap { $0.title }, selectedIndex: MicroFineType.selectedMicrophone.rawValue, delegate: self)
        let segmentCellConfig = SimpleSegmentTableViewCellConfig(item: segmentCellModel)
        
        let musicModeCellModel = SettingTableViewCellModel(title: "Music mode".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isMusicModeEnabled, delegate: self)
        let musicCellConfig = SettingTableViewCellConfig(item: musicModeCellModel)
        
        let systemVolumeCellModel = SettingTableViewCellModel(title: "Use system volume".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isUseSystemVolume, delegate: self)
        let systemVolumeCellConfig = SettingTableViewCellConfig(item: systemVolumeCellModel)
        
        let clearVoiceCellModel = SettingTableViewCellModel(title: "Clear voice".localized(), buttonTypes: [.info, .switchButton], switchState: AudioKitService.shared.isClearVoice, delegate: self)
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
        
        AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ProSetupViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - SimpleSegmentTableViewCellDelegate
extension ProSetupViewController: SimpleSegmentTableViewCellDelegate {
    
    func didSelectSegment(with index: Int, from cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              var cellModel = dataSource[safe: indexPath.row]?.getItem() as? SimpleSegmentTableViewCellModel else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.changeMicrophone(on: MicroFineType(rawValue: index)!)
        
        cellModel.selectedIndex = MicroFineType.selectedMicrophone.rawValue
        let cellConfig = SimpleSegmentTableViewCellConfig(item: cellModel)
        dataSource[indexPath.row] = cellConfig
        delegate?.didChangeMicrophone()
        
        let selectedMicrophoneString = String(describing: MicroFineType.selectedMicrophone)
        AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.changeMicrophone.rawValue)_\(selectedMicrophoneString)"])
    }
}

// MARK: - VCentereButnTableViewCellDelegate
extension ProSetupViewController: VCentereButnTableViewCellDelegate {
    
    func didSelectButton(from cell: VCentereButnTableViewCell) {
        TapticEngine.impact.feedback(.medium)
        AudioKitService.shared.changeMicrophone(on: MicroFineType.defaultMicrophone)
        AudioKitService.shared.setMusicMode(false)
        AudioKitService.shared.setUseSystemVolume(false)
        AudioKitService.shared.setClearVoice(false)
        configureDataSource()
        delegate?.didUpdateSystemVolumeValue()
        delegate?.didChangeMicrophone()
        
        AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.reset.rawValue])
    }
}

// MARK: - SettingTableViewCellDelegate
extension ProSetupViewController: SettingTableViewCellDelegate {
    
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
                
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.musicMode.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !AudioKitService.shared.isMusicModeEnabled
                AudioKitService.shared.setMusicMode(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.musicMode.rawValue)_\(stringState)"])
            default:
                break
            }
        case 2: // System volume
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "Increase Volume of Hearing Aid together with the device system volume".localized())
                
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.systemVolume.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !AudioKitService.shared.isUseSystemVolume
                AudioKitService.shared.setUseSystemVolume(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                delegate?.didUpdateSystemVolumeValue()
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.systemVolume.rawValue)_\(stringState)"])
            default:
                break
            }
        case 3: // Clear Voice
            switch type {
            case .info:
                presentAlertPM(title: "Info".localized(), message: "AI helps to pick a voice out from the background noise and other sounds".localized())
                
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.clearVoice.rawValue)_\(GAppAnalyticActions.info.rawValue)"])
            case .switchButton:
                let newState = !AudioKitService.shared.isClearVoice
                AudioKitService.shared.setClearVoice(newState)
                let newCellModel = SettingTableViewCellModel(title: cellModel.title, buttonTypes: cellModel.buttonTypes, switchState: newState, delegate: self)
                dataSource[indexRow] = SettingTableViewCellConfig(item: newCellModel)
                
                let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
                AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.clearVoice.rawValue)_\(stringState)"])
            default:
                break
            }
        case 4:
            AppsNavManager.shared.pushVoiceChangerViewController()
            AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.voiceChanger.rawValue])
        case 5: // Compressor
            AppsNavManager.shared.pushCompressorViewController()
            AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.compressor.rawValue])
        case 6: // Limiter
            AppsNavManager.shared.pushLimiterViewController()
            AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.limiter.rawValue])
        case 7: // Equalizer
            AppsNavManager.shared.pushEqualizerViewController()
            AppConfiguration.shared.analytics.track(action: .v2HearingProSetupScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.equalizer.rawValue])
        default:
            break
        }
    }
}
