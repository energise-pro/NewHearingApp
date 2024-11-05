import UIKit

protocol GTranscriptionTablViewCellDelegate: AnyObject {
    func didSelectTranscript(from cell: GTranscriptionTablViewCell)
}

struct GTranscriptionTablViewCellModel {
    var transcriptModel: TranscribeModel
    weak var delegate: GTranscriptionTablViewCellDelegate?
}

typealias GTranscriptionTablViewCellConfig = АViewCellConfig<GTranscriptionTablViewCell, GTranscriptionTablViewCellModel>

final class GTranscriptionTablViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = GTranscriptionTablViewCellModel
    
    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private weak var delegate: GTranscriptionTablViewCellDelegate?
    
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
