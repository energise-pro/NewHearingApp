import UIKit

protocol HTranscripTableViewCellDelegate: AnyObject {
    func didSelectTranscript(from cell: HTranscripTableViewCell)
}

struct HTranscripTableViewCellModel {
    var transcriptModel: TranscribeModel
    weak var delegate: HTranscripTableViewCellDelegate?
}

typealias HTranscripTableViewCellConfig = ViewCellConfigurator<HTranscripTableViewCell, HTranscripTableViewCellModel>

final class HTranscripTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = HTranscripTableViewCellModel
    
    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private weak var delegate: HTranscripTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        titleLabel.text = data.transcriptModel.title
        dateLabel.text = Date(timeIntervalSince1970: data.transcriptModel.createdDate).toDateWithTime()
        
        dateLabel.textColor = UIColor.appColor(.UnactiveButton_2)
    }
    
    // MARK: - IBActions
    @IBAction private func mainButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        delegate?.didSelectTranscript(from: self)
    }
}
