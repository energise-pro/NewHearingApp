import UIKit

protocol SCentButtnTablViewCellDelegate: AnyObject {
    func didSelectButton(from cell: SCentButtnTablViewCell)
}

struct SCentButtnTablViewCellModel {
    var buttonTitle: String
    var buttonImage: UIImage
    weak var delegate: SCentButtnTablViewCellDelegate?
}

typealias SCentButtnTablViewCellConfig = ViewCellConfigurator<SCentButtnTablViewCell, SCentButtnTablViewCellModel>

final class SCentButtnTablViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = SCentButtnTablViewCellModel

    // MARK: - Properties
    @IBOutlet private weak var buttonTitleLabel: UILabel!
    @IBOutlet private weak var buttonImageView: UIImageView!
    
    private weak var delegate: SCentButtnTablViewCellDelegate?
    
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
