import UIKit

protocol VCentereButnTableViewCellDelegate: AnyObject {
    func didSelectButton(from cell: VCentereButnTableViewCell)
}

struct VCentereButnTableViewCellModel {
    var buttonTitle: String
    var buttonImage: UIImage
    weak var delegate: VCentereButnTableViewCellDelegate?
}

typealias VCentereButnTableViewCellConfig = АViewCellConfig<VCentereButnTableViewCell, VCentereButnTableViewCellModel>

final class VCentereButnTableViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = VCentereButnTableViewCellModel

    // MARK: - Properties
    @IBOutlet private weak var buttonTitleLabel: UILabel!
    @IBOutlet private weak var buttonImageView: UIImageView!
    
    private weak var delegate: VCentereButnTableViewCellDelegate?
    
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
