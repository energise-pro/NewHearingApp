import UIKit

protocol NSimplSementTablViewCellDelegate: AnyObject {
    func didSelectSegment(with index: Int, from cell: UITableViewCell)
}

struct NSimplSementTablViewCellModel {
    var mainTitle: String
    var titles: [String]
    var selectedIndex: Int
    weak var delegate: NSimplSementTablViewCellDelegate?
}

typealias NSimplSementTablViewCellConfig = АViewCellConfig<NSimplSementTablViewCell, NSimplSementTablViewCellModel>

final class NSimplSementTablViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {
    
    typealias DataType = NSimplSementTablViewCellModel

    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var segmentControll: UISegmentedControl!
    
    private weak var delegate: NSimplSementTablViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        segmentControll.replaceSegments(segments: data.titles)
        segmentControll.selectedSegmentIndex = data.selectedIndex
        segmentControll.setTitleTextAttributes([.foregroundColor: UIColor.appColor(.Purple100)!], for: .normal)
        segmentControll.overrideUserInterfaceStyle = .light
        titleLabel.text = data.mainTitle
    }
    
    // MARK: - IBActions
    @IBAction private func segmentValueChanged(_ sender: UISegmentedControl) {
        delegate?.didSelectSegment(with: sender.selectedSegmentIndex, from: self)
    }
}
