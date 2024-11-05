import UIKit

protocol UThemNTablViewCellDelegate: AnyObject {
    func didSelectTheme(with type: ColorType, from cell: UThemNTablViewCell)
}

struct UThemNTablViewCellModel {
    var title: String
    var selectedTheme: ColorType
    var themes: [ColorType]
    weak var delegate: UThemNTablViewCellDelegate?
}

typealias UThemNTablViewCellConfig = АViewCellConfig<UThemNTablViewCell, UThemNTablViewCellModel>

final class UThemNTablViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = UThemNTablViewCellModel
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var mainStackView: UIStackView!
    
    @IBOutlet private weak var separatorView: UIView!
    
    private weak var delegate: UThemNTablViewCellDelegate?
    private var themes: [ColorType] = []
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = UIColor.label.withAlphaComponent(0.3)
    }
    
    func configure(data: DataType) {
        delegate = data.delegate
        titleLabel.text = data.title
        themes = data.themes
        mainStackView.arrangedSubviews.enumerated().forEach { index, view in
            let currentTheme = data.themes[safe: index]
            view.backgroundColor = currentTheme?.color
            view.tintColor = .white
            view.alpha = currentTheme == data.selectedTheme ? 1.0 : 0.4
        }
    }
    
    // MARK: - IBActions
    @IBAction private func buttonAction(_ sender: UIButton) {
        guard let themeColor = themes[safe: sender.tag] else {
            return
        }
        delegate?.didSelectTheme(with: themeColor, from: self)
        mainStackView.arrangedSubviews.enumerated().forEach { index, view in
            view.alpha = index == sender.tag ? 1.0 : 0.4
        }
    }
}
