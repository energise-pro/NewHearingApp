import UIKit

protocol SpeechRecognitionSettingsDelegate: AnyObject {
    func didChangeFontSize(_ size: Float)
    func didChangeFontWeight( _ weight: Int)
    func didChangeTextAlignment(_ alignment: NSTextAlignment)
    func didToggleSetting(_ setting:SpeechRecognitionSettings, _ value: Bool)
}

final class SpeechRecognitionSettingsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!

    var settings: [SpeechRecognitionSettings] {
        return SpeechRecognitionSettings.allCases
    }

    weak var delegate: SpeechRecognitionSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings".localized()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func fontSizeChangeContinuousAction(sender: UISlider) {
        delegate?.didChangeFontSize(sender.value)
    }

    @IBAction func fontSizeDidChangeAction(sender: UISlider) {
        let value = sender.value
        SpeechRecognitionSettings.FontSize.setValue(value)
        TapticEngine.selection.feedback()
        
        AppConfigService.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeFontSize.rawValue])
    }

    @IBAction func switchAction(sender: UISwitch) {
        guard let cell = tableView.cell(sender), let indexPath = tableView.indexPath(for: cell) else { return }
        let setting = settings[indexPath.row]
        setting.setValue(sender.isOn)
        delegate?.didToggleSetting(setting, sender.isOn)
        TapticEngine.impact.feedback(.medium)
        
        switch setting {
        case .TranslateMode:
            let stringState = sender.isOn ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
            AppConfigService.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.translateMode.rawValue)_\(stringState)"])
        case .ShakeToClearText:
            let stringState = sender.isOn ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
            AppConfigService.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.shakeClearText.rawValue)_\(stringState)"])
        default:
            break
        }
    }

    @IBAction func alignmentAction(sender: UIButton) {
        guard let cell = tableView.cell(sender) as? AlignmentCell else { return }
        let tag = sender.tag
        let alignment = NSTextAlignment.init(rawValue: tag) ?? .left
        cell.setAlignment(alignment)
        delegate?.didChangeTextAlignment(alignment)
        SpeechRecognitionSettings.TextAlignment.setValue(alignment.rawValue)
        
        AppConfigService.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(AnalyticsAction.alignment.rawValue)"])
    }

    @IBAction func fontWeightAction(sender: UIButton) {
        guard let cell = tableView.cell(sender) as? FontWeightCell else { return }
        let weight = sender.tag
        cell.setFontWeight(weight)
        delegate?.didChangeFontWeight(weight)
        SpeechRecognitionSettings.FontWeight.setValue(weight)
        
        AppConfigService.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.change.rawValue)_\(AnalyticsAction.weight.rawValue)"])
    }
    
    //MARK: - Deinit
    deinit {
//        var analyticsParams: [String: String] = [:]
//        settings.forEach { setting in
//            switch setting {
//            case .FontSize:
//                if let value = setting.value as? Float {
//                    analyticsParams[AnalyticsAction.fontSize.rawValue] = "\(value)"
//                }
//            case .FontWeight:
//                if let value = setting.value as? Float {
//                    analyticsParams[AnalyticsAction.fontWeight.rawValue] = "\(value)"
//                }
//            case .TextAlignment:
//                if let value = setting.value as? Int {
//                    var alignment = ""
//                    switch value {
//                    case 0:
//                        alignment = AnalyticsAction.left.rawValue
//                    case 1:
//                        alignment = AnalyticsAction.center.rawValue
//                    case 2:
//                        alignment = AnalyticsAction.right.rawValue
//                    case 3:
//                        alignment = AnalyticsAction.fullScreen.rawValue
//                    default:
//                        break
//                    }
//                    analyticsParams[AnalyticsAction.textAlignment.rawValue] = alignment
//                }
//            case .TranslateMode:
//                if let value = setting.value as? Bool {
//                    analyticsParams[AnalyticsAction.translateMode.rawValue] = value ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
//                }
//            case .ShakeToClearText:
//                if let value = setting.value as? Bool {
//                    analyticsParams[AnalyticsAction.shakeClearText.rawValue] = value ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
//                }
//            case .AmplitudeIndicator:
//                if let value = setting.value as? Bool {
//                    analyticsParams[AnalyticsAction.qualityIndicator.rawValue] = value ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue
//                }
//            }
//        }
//        AppConfigService.shared.analytics.track(action: .settingsHearingAid, with: [AnalyticsAction.parameters.rawValue: analyticsParams])
    }
}

extension SpeechRecognitionSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.cellId, for: indexPath) as! BaseSettingCell
        cell.setting = setting
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        let setting = settings[indexPath.row]
        return setting.rowHeight
    }
}

final class SliderCell: BaseSettingCell {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!

    override var setting: SpeechRecognitionSettings? {
        didSet {
            guard let setting = setting else { return }
            slider.minimumValue = setting.minValue as! Float
            slider.maximumValue = setting.maxValue as! Float
            slider.value = setting.value as! Float
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()

        NotificationCenter.default.addObserver(self, selector: #selector(setupUIColor), name: ThemeDidChangeNotificationName, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func setupUIColor() {
        minLabel.textColor = Theme.buttonActiveColor
        maxLabel.textColor = Theme.buttonActiveColor
        slider.minimumTrackTintColor = Theme.buttonActiveColor
    }
}

final class SwitchCell: BaseSettingCell {
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var iconImageView: UIImageView!

    override var setting: SpeechRecognitionSettings? {
        didSet {
            guard let setting = setting else { return }
            switchControl.isOn = setting.value as? Bool ?? false
            iconImageView.image = setting.icon
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIColor()

        NotificationCenter.default.addObserver(self, selector: #selector(setupUIColor), name: ThemeDidChangeNotificationName, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func setupUIColor() {
        switchControl.onTintColor = Theme.buttonActiveColor
        iconImageView.tintColor = Theme.buttonActiveColor
    }
}

final class AlignmentCell: BaseSettingCell {
    @IBOutlet weak var left: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var right: UIButton!
    @IBOutlet weak var justified: UIButton!
    @IBOutlet weak var natural: UIButton!

    override var setting: SpeechRecognitionSettings? {
        didSet {
            guard let setting = setting else { return }
            let alignment = NSTextAlignment(rawValue: setting.value as! Int) ?? .left
            setAlignment(alignment)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let alignment = NSTextAlignment(rawValue: SpeechRecognitionSettings.TextAlignment.value as! Int) ?? .left
        setAlignment(alignment)
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        let buttons = [left, centerButton, right, justified, natural].compactMap({$0})
        buttons.forEach({ $0.tintColor = Theme.buttonInactiveColor; $0.setTitleColor(Theme.buttonInactiveColor, for: .normal) })
        let selectedButton = buttons.filter({ $0.tag == alignment.rawValue }).first
        selectedButton?.tintColor = Theme.buttonActiveColor
        selectedButton?.setTitleColor(Theme.buttonActiveColor, for: .normal)
    }
}

final class FontWeightCell: BaseSettingCell {
    @IBOutlet weak var regular: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var bold: UIButton!

    var buttons:[UIButton] {
        return [regular,medium,bold]
    }

    override var setting: SpeechRecognitionSettings? {
        didSet {
            guard let setting = setting else { return }
            let weight = setting.value as! Int
            setFontWeight(weight)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let fontWeight = SpeechRecognitionSettings.FontWeight.value as! Int
        setFontWeight(fontWeight)
    }

    func setFontWeight(_ weight: Int) {
        buttons.forEach({ $0.tintColor = Theme.buttonInactiveColor; $0.setTitleColor(Theme.buttonInactiveColor, for: .normal) })
        let selectedButton = buttons.filter({ $0.tag == weight }).first
        selectedButton?.tintColor = Theme.buttonActiveColor
        selectedButton?.setTitleColor(Theme.buttonActiveColor, for: .normal)
    }
}

open class BaseSettingCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?

    var setting: SpeechRecognitionSettings? {
        didSet {
            guard let setting = setting else { return }
            titleLabel?.text = setting.title
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textColor = Theme.buttonActiveColor
    }
}


enum SpeechRecognitionSettings: String, CaseIterable {
    case FontSize, FontWeight, TextAlignment,
         TranslateMode, ShakeToClearText //, AmplitudeIndicator

    var cellId: String {
        switch self {
        case .FontSize:
            return "SliderCell"
        case .FontWeight:
            return "FontWeightCell"
        case .TextAlignment:
            return "AlignmentCell"
        case .ShakeToClearText:
            return "SwitchCell"
        case .TranslateMode:
            return "SwitchCell"
//        case .AmplitudeIndicator:
//            return "SwitchCell"
        }
    }

    var minValue: Any {
        switch self {
        case .FontSize:
            return Float(20)
        case .FontWeight:
            return 0
        case .TextAlignment:
            return NSTextAlignment.left.rawValue
        case .ShakeToClearText, .TranslateMode://, .AmplitudeIndicator:
            return false
        }
    }

    var maxValue: Any {
        switch self {
        case .FontSize:
            return iPhone ? Float(200) : Float(300)
        case .FontWeight:
            return 2
        case .TextAlignment:
            return NSTextAlignment.natural.rawValue
        case .ShakeToClearText, .TranslateMode://, .AmplitudeIndicator:
            return true
        }
    }

    var defaultValue: Any {
        switch self {
        case .FontSize:
            return Float(50)
        case .FontWeight:
            return 2
        case .TextAlignment:
            return NSTextAlignment.center.rawValue
        case .ShakeToClearText, .TranslateMode:
            return false
//        case .AmplitudeIndicator:
//            return true
        }
    }

    var rowHeight: CGFloat {
        return 70
    }

    var title: String {
        switch self {
        case .FontSize:
            return "Font Size".localized()
        case .FontWeight:
            return "Font Weight".localized()
        case .TextAlignment:
            return "Text Alignment".localized()
        case .ShakeToClearText:
            return "Shake to clear text".localized()
        case .TranslateMode:
            return "Translate Mode".localized()
//        case .AmplitudeIndicator:
//            return "Show Quality Indicator".localized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .ShakeToClearText:
            return UIImage(named: "shake phone")
        case .TranslateMode:
            return UIImage(systemName: "globe")
        default:
            return nil
        }
    }

    var value: Any {
        return UserDefaults.standard.value(forKey: self.rawValue) ?? defaultValue
    }

    func setValue(_ value: Any) {
        UserDefaults.standard.setValue(value, forKey: self.rawValue)
    }
}
