import UIKit

protocol CenterButtonTableViewCellDelegate: AnyObject {
    func didSelectButton(from cell: CenterButtonTableViewCell)
}

struct CenterButtonTableViewCellModel {
    var buttonTitle: String
    var buttonImage: UIImage
    weak var delegate: CenterButtonTableViewCellDelegate?
}

typealias CenterButtonTableViewCellConfig = ViewCellConfigurator<CenterButtonTableViewCell, CenterButtonTableViewCellModel>

final class CenterButtonTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = CenterButtonTableViewCellModel

    // MARK: - Properties
    @IBOutlet private weak var buttonTitleLabel: UILabel!
    @IBOutlet private weak var buttonImageView: UIImageView!
    
    private weak var delegate: CenterButtonTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        buttonTitleLabel.text = data.buttonTitle
        buttonImageView.image = data.buttonImage
        buttonImageView.tintColor = UIColor.label
    }
    
    // MARK: - IBActions
    @IBAction private func buttonAction(_ sender: UIButton) {
        delegate?.didSelectButton(from: self)
    }
}
