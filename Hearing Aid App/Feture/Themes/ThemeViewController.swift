//
//  ThemeViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/12/21.
//

import UIKit
import MessageUI

final class ThemeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet private weak var maskView: UIView!
    
    private var rows: [ThemeSettingsRow] {
        return ThemeSettingsRow.allCases.filter({$0 != .UnlockPremium })
    }

    override func didUpdateSubscriptionInfo() {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Settings".localized()
        titleLabel.textColor = Theme.buttonActiveColor
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        AppConfigService.shared.analytics.track(action: .settingsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
        maskView.isHidden = true
        tableView.reloadData()
    }

    @IBAction func controlsColorChangeAction(sender: UIButton) {
        guard let color = Theme.Color(rawValue: sender.tag) else {
            return
        }
        Theme.setControlsColor(color)
        titleLabel.textColor = Theme.buttonActiveColor
//        AppConfigService.shared.analytics.track(action: .appColor, with: [AnalyticsAction.color.rawValue: color.titleAnalysticsColor])
    }

    @IBAction func switchAction(sender: UISwitch) {
        guard let cell = tableView.cell(sender),
        let index = tableView.indexPath(for: cell)?.row else { return }
        let row = rows[index]
        switch row {
//        case .DarkMode:
//            Theme.enableDarkMode = sender.isOn
//            AppConfigService.shared.analytics.track(action: .darkMode, with: [AnalyticsAction.action.rawValue: sender.isOn ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue])
        case .TapticOption:
//            AppConfigService.shared.analytics.track(action: .haptiFeedback, with: [AnalyticsAction.action.rawValue: sender.isOn ? AnalyticsAction.enable.rawValue : AnalyticsAction.disable.rawValue])
            TapticEngine.isOn = sender.isOn
            ThemeSettingsRow.TapticOption.setValue(sender.isOn)
        default:
            break
        }
    }

    @IBAction func hapticQuestionOption(sender:UIButton) {
        let title = "Info".localized()
        let message = "Disable or Enable vibrations when you press UI buttons".localized()
        presentAlert(controller: self, title: title, message: message)
    }
}

extension ThemeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellId, for: indexPath) as! BaseThemeCell
        cell.row = row
        cell.selectionStyle = row.selectionStyle
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ?  Theme.buttonInactiveColor.withAlphaComponent(0.1) : view.backgroundColor
        if row == .UnlockPremium, let cell = cell as? DetailsCell {
            cell.subtitleLabel?.isHidden = false
            let endTrial = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let discountText = "-50% expire at: \(formatter.string(from: endTrial)), your demo access ends at:\(formatter.string(from: endTrial))"
            cell.subtitleLabel?.text = discountText
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        } else if let cell = cell as? DetailsCell {
            cell.subtitleLabel?.text = ""
            cell.subtitleLabel?.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        switch row {
        case .RestorePurchase:
//            AppConfigService.shared.analytics.track(action: .restorePurchase, with: [AnalyticsAction.action.rawValue: AnalyticsAction.click.rawValue])
            let title = "Restore Purchase".localized()
            presentAlert(controller: self, title: title, message: "", leftActionTitle: "Yes!".localized(), rightActionTitle: "No".localized(), leftActionStyle: .default, rightActionStyle: .default) { [weak self] in
                guard let self = self else {
                    return
                }
                ActivityIndicatorView.showActivity(topView: self.view)
                InAppPurchasesService.shared.restorePurchases { isSuccess in
                    ActivityIndicatorView.hideActivity()
                    presentAlert(controller: self, title: isSuccess ? "Completed" : "Failed", message: "")
                }
            } rightActionCompletion: {}
        case .ChangeAppIcon:
            let size = CGSize(width: 340, height: 172)
            let alternateIconsViewController: AlternateIconsViewController = AlternateIconsViewController.presentOn(controller: self, inView: view, withSize: size)
            maskView.backgroundColor = Theme.enableDarkMode ? .white : .black
            maskView.isHidden = false
            alternateIconsViewController.delegate = self
        case .Support:
//            AppConfigService.shared.analytics.track(action: .support, with: [AnalyticsAction.action.rawValue: AnalyticsAction.click.rawValue])
            sendEmail()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rows[indexPath.row].rowHeight
    }
}

//MARK: - AlternateIconsViewControllerDelegate
extension ThemeViewController: AlternateIconsViewControllerDelegate {
    
    func dismiss() {
        maskView.isHidden = true
    }
}

extension ThemeViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.General.supportEmail])
            mail.setSubject("Hearing Aid App Support")
            present(mail, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

final class ControlsColorCell: BaseThemeCell {
    @IBOutlet weak var pinkButton:UIButton!
    @IBOutlet weak var orangeButton:UIButton!
    @IBOutlet weak var redButton:UIButton!
    @IBOutlet weak var blueButton:UIButton!
    @IBOutlet weak var greenButton:UIButton!

    var buttons: [UIButton] {
        return [pinkButton, orangeButton, redButton, blueButton, greenButton]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        buttons.forEach({
            $0.tintColor = Theme.Color(rawValue: $0.tag)?.color
            $0.backgroundColor = UIColor.systemBackground
            $0.layer.cornerRadius = 5
            $0.layer.masksToBounds = true
            $0.addShadow()
        })
    }
}

final class ThemeSwitchCell: BaseThemeCell {
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var iconImageView: UIImageView!

    override var row: ThemeSettingsRow? {
        didSet {
            guard let row = row else { return }
            switchControl.isOn = row.value as? Bool ?? false
            iconImageView.image = row.icon
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


final class DetailsCell: BaseThemeCell {
    @IBOutlet weak var subtitleLabel: UILabel?
}

class BaseThemeCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    var row: ThemeSettingsRow? {
        didSet {
            titleLabel.textColor = Theme.buttonInactiveColor
            titleLabel.text = row?.title ?? ""
        }
    }
}

enum ThemeSettingsRow: String, CaseIterable {
    case ControlsColor, ChangeAppIcon, TapticOption, RestorePurchase, UnlockPremium, Support

    var title: String {
        switch self {
        case .ControlsColor:
            return "Controls Color".localized()
//        case .DarkMode:
//            return "Dark Mode".localized()
        case .ChangeAppIcon:
            return "Change App Icon".localized()
        case .TapticOption:
            return "Use Haptic Feedback".localized()
        case .RestorePurchase:
            return "Restore Purchase".localized()
        case .UnlockPremium:
            return "Unlock Premium".localized()
        case .Support:
            return "Support & Feature Request".localized()
        }
    }

    var cellId: String {
        switch self {
        case .ControlsColor, .TapticOption: //.DarkMode
            return self.rawValue
        case .ChangeAppIcon, .RestorePurchase, .Support, .UnlockPremium:
            return "DetailsCell"
        }
    }

    var selectionStyle: UITableViewCell.SelectionStyle {
        switch self {
        case .ControlsColor, .TapticOption: //.DarkMode
            return .none
        case .ChangeAppIcon, .RestorePurchase, .Support, .UnlockPremium:
            return .default
        }
    }

    var rowHeight: CGFloat {
        return 88
    }

    var icon: UIImage? {
        return nil
//        switch self {
//        case .DarkMode:
//            return UIImage(systemName: "paintbrush.fill")
//        default:
//            return nil
//        }
    }

    var defaultValue: Any {
        switch self {
        case .ControlsColor:
            return Theme.Color.red.rawValue
        case .TapticOption:
            return true
//        case .DarkMode:
//            return UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark
        case .ChangeAppIcon, .RestorePurchase, .Support, .UnlockPremium:
            return 1
        }
    }

    var value: Any {
        return UserDefaults.standard.value(forKey: self.rawValue) ?? defaultValue
    }

    func setValue(_ value: Any) {
        UserDefaults.standard.synchronize()
        UserDefaults.standard.setValue(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
}
