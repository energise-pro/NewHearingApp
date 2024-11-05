import UIKit

enum SettingTableViewButtonType: Int {
    case info
    case switchButton
    case rightButton
    case loader
}

protocol SettingTableViewCellDelegate: AnyObject {
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell)
}

struct SettingTableViewCellModel {
    var title: String?
    var attributedTitle: NSAttributedString? = nil
    var buttonTypes: [SettingTableViewButtonType]
    var switchState: Bool = false
    var topInset: CGFloat = 0.0
    var rightImage: UIImage? = UIImage.init(systemName: "chevron.right")
    var rightTintColor: UIColor? = UIColor.label.withAlphaComponent(0.3)
    weak var delegate: SettingTableViewCellDelegate?
}

typealias SettingTableViewCellConfig = АViewCellConfig<SettingTableViewCell, SettingTableViewCellModel>

final class SettingTableViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = SettingTableViewCellModel
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    
    @IBOutlet private weak var mainSwitch: UISwitch!
    @IBOutlet private weak var mainButton: UIButton!
    
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var loaderActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var containerViewTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: SettingTableViewCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme), name: ThemeDidChangeNotificationName, object: nil)
        
        infoImageView.image = UIImage.init(systemName: "info.circle")
        separatorView.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        
        didChangeTheme()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonsStackView.arrangedSubviews.enumerated().forEach { $0.element.isHidden = $0.offset != SettingTableViewButtonType.rightButton.rawValue }
        containerViewTopConstraint.constant = .zero
        mainButton.isHidden = false
    }
    
    func configure(data: DataType) {
        delegate = data.delegate
        if let attributedTitle = data.attributedTitle {
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = data.title
        }
        buttonsStackView.arrangedSubviews.enumerated().forEach { $0.element.isHidden = !data.buttonTypes.contains(SettingTableViewButtonType(rawValue: $0.offset)!) }
        mainSwitch.isOn = data.switchState
        mainButton.isHidden = !data.buttonTypes.contains(.rightButton)
        containerViewTopConstraint.constant = data.topInset
        
        if data.buttonTypes.contains(.rightButton) {
            rightImageView.image = data.rightImage
            rightImageView.tintColor = data.rightTintColor
        }
        
        if data.buttonTypes.contains(.loader) {
            loaderActivityIndicator.startAnimating()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    @objc private func didChangeTheme() {
        infoImageView.tintColor = AThemeServicesAp.shared.activeColor
        mainSwitch.onTintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - IBActions
    @IBAction private func buttonAction(_ sender: UIButton) {
        guard let buttonType = SettingTableViewButtonType(rawValue: sender.tag) else {
            return
        }
        delegate?.didSelectButton(with: buttonType, from: self)
    }
    
    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        delegate?.didSelectButton(with: .switchButton, from: self)
    }
}
