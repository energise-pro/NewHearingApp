//
//  NewSettingWithSubtitleTableViewCell.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 11.12.2024.
//

import UIKit

enum NewSettingWithSubtitleTableViewButtonType: Int {
    case info
    case switchButton
    case rightButton
    case leftButtonImage
}

protocol NewSettingWithSubtitleTableViewCellDelegate: AnyObject {
    func didSelectButton(with type: NewSettingWithSubtitleTableViewButtonType, from cell: NewSettingWithSubtitleTableViewCell)
}

struct NewSettingWithSubtitleTableViewCellModel {
    var cellId: String?
    var title: String?
    var attributedTitle: NSAttributedString? = nil
    var subtitle: String?
    var buttonTypes: [NewSettingWithSubtitleTableViewButtonType]
    var switchState: Bool = false
    var topInset: CGFloat = 0.0
    var rightImage: UIImage? = UIImage.init(named: "arrowOpenImage")
    var rightTintColor: UIColor? = UIColor.appColor(.Purple100)
    var leftImage: UIImage?
    weak var delegate: NewSettingWithSubtitleTableViewCellDelegate?
}

typealias NewSettingWithSubtitleTableViewCellConfig = АViewCellConfig<NewSettingWithSubtitleTableViewCell, NewSettingWithSubtitleTableViewCellModel>

final class NewSettingWithSubtitleTableViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = NewSettingWithSubtitleTableViewCellModel
    
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    
    @IBOutlet private weak var mainSwitch: UISwitch!
    @IBOutlet private weak var mainButton: UIButton!
    
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var containerViewTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: NewSettingWithSubtitleTableViewCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme), name: ThemeDidChangeNotificationName, object: nil)
        
        infoImageView.image = CAppConstants.Images.icInstructionInfo
        separatorView.backgroundColor = UIColor.appColor(.TableSeparator100)
        
        didChangeTheme()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonsStackView.arrangedSubviews.enumerated().forEach { $0.element.isHidden = $0.offset != NewSettingWithSubtitleTableViewButtonType.rightButton.rawValue }
        containerViewTopConstraint.constant = .zero
        mainButton.isHidden = false
        leftImageView.isHidden = true
    }
    
    func configure(data: DataType) {
        delegate = data.delegate
        if let attributedTitle = data.attributedTitle {
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = data.title
        }
        subtitleLabel.text = data.subtitle
        buttonsStackView.arrangedSubviews.enumerated().forEach { $0.element.isHidden = !data.buttonTypes.contains(NewSettingWithSubtitleTableViewButtonType(rawValue: $0.offset)!) }
        mainSwitch.isOn = data.switchState
        mainButton.isHidden = !data.buttonTypes.contains(.rightButton)
        containerViewTopConstraint.constant = data.topInset
        
        if data.buttonTypes.contains(.rightButton) {
            rightImageView.image = data.rightImage
            rightImageView.tintColor = data.rightTintColor
        }
        
        if data.buttonTypes.contains(.leftButtonImage) {
            leftImageView.isHidden = false
            leftImageView.image = data.leftImage
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
        guard let buttonType = NewSettingWithSubtitleTableViewButtonType(rawValue: sender.tag) else {
            return
        }
        delegate?.didSelectButton(with: buttonType, from: self)
    }
    
    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        delegate?.didSelectButton(with: .switchButton, from: self)
    }
}


