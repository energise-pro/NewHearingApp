import UIKit

protocol МCentrPikrTableViewCellDelegate: AnyObject {
    func didSelect(_ value: String?, from cell: МCentrPikrTableViewCell)
}

struct МCentrPikrTableViewCellModel {
    var dataSource: [String]
    var selectedValue: String?
    weak var delegate: МCentrPikrTableViewCellDelegate?
}

typealias МCentrPikrTableViewCellConfig = ViewCellConfigurator<МCentrPikrTableViewCell, МCentrPikrTableViewCellModel>

final class МCentrPikrTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = МCentrPikrTableViewCellModel
    
    @IBOutlet private weak var pickerView: UIPickerView!
    
    private var dataSource: [String] = []
    private weak var delegate: МCentrPikrTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        dataSource = data.dataSource
        pickerView.reloadAllComponents()
        if let selectedValue = data.selectedValue, let indexRow = data.dataSource.firstIndex(of: selectedValue) {
            pickerView.selectRow(indexRow, inComponent: 0, animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension МCentrPikrTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelect(dataSource[safe: row], from: self)
    }
}
