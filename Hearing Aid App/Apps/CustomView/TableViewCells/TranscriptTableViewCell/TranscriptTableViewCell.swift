import UIKit

protocol TranscriptTableViewCellDelegate: AnyObject {
    func didSelectTranscript(from cell: TranscriptTableViewCell)
}

struct TranscriptTableViewCellModel {
    var transcriptModel: TranscribeModel
    weak var delegate: TranscriptTableViewCellDelegate?
}

typealias TranscriptTableViewCellConfig = ViewCellConfigurator<TranscriptTableViewCell, TranscriptTableViewCellModel>

final class TranscriptTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = TranscriptTableViewCellModel
    
    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private weak var delegate: TranscriptTableViewCellDelegate?
    
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
