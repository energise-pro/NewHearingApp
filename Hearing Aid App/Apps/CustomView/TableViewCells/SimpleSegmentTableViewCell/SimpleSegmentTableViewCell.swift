import UIKit

protocol SimpleSegmentTableViewCellDelegate: AnyObject {
    func didSelectSegment(with index: Int, from cell: UITableViewCell)
}

struct SimpleSegmentTableViewCellModel {
    var mainTitle: String
    var titles: [String]
    var selectedIndex: Int
    weak var delegate: SimpleSegmentTableViewCellDelegate?
}

typealias SimpleSegmentTableViewCellConfig = ViewCellConfigurator<SimpleSegmentTableViewCell, SimpleSegmentTableViewCellModel>

final class SimpleSegmentTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {
    
    typealias DataType = SimpleSegmentTableViewCellModel

    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var segmentControll: UISegmentedControl!
    
    private weak var delegate: SimpleSegmentTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        segmentControll.replaceSegments(segments: data.titles)
        segmentControll.selectedSegmentIndex = data.selectedIndex
        titleLabel.text = data.mainTitle
    }
    
    // MARK: - IBActions
    @IBAction private func segmentValueChanged(_ sender: UISegmentedControl) {
        delegate?.didSelectSegment(with: sender.selectedSegmentIndex, from: self)
    }
}
