import UIKit

protocol TextParametersTableViewCellDelegate: AnyObject {
    func didChangeValue(value: Int, for parameter: TranscribeTextParameter, from cell: TextParametersTableViewCell)
}

struct TextParametersTableViewCellModel {
    weak var delegate: TextParametersTableViewCellDelegate?
}

typealias TextParametersTableViewCellConfig = ViewCellConfigurator<TextParametersTableViewCell, TextParametersTableViewCellModel>

final class TextParametersTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = TextParametersTableViewCellModel
    
    // MARK: - Properties
    @IBOutlet private weak var fontSizeTitleLabel: UILabel!
    @IBOutlet private weak var fontWeightTitleLabel: UILabel!
    @IBOutlet private weak var alignmentTitleLabel: UILabel!
    
    @IBOutlet private weak var fontSizeSlider: UISlider!
    
    @IBOutlet private var fontWeightLabels: [UILabel]!
    
    @IBOutlet private var alignmentImageViews: [UIImageView]!
    
    private weak var delegate: TextParametersTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        configureUI()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        fontSizeTitleLabel.text = TranscribeTextParameter.FontSize.title
        fontWeightTitleLabel.text = TranscribeTextParameter.FontWeight.title
        alignmentTitleLabel.text = TranscribeTextParameter.TextAlignment.title
        
        fontSizeSlider.tintColor = ThemeService.shared.activeColor.withAlphaComponent(0.7)
        
        fontSizeSlider.minimumValue = Float(TranscribeTextParameter.FontSize.minValue)
        fontSizeSlider.maximumValue = Float(TranscribeTextParameter.FontSize.maxValue)
        fontSizeSlider.value = Float(TranscribeTextParameter.FontSize.value)
        
        fontWeightLabels.enumerated().forEach { $0.element.textColor = $0.offset == TranscribeTextParameter.FontWeight.value ? ThemeService.shared.activeColor : UIColor.label }
        
        alignmentImageViews.enumerated().forEach { $0.element.tintColor = $0.offset == TranscribeTextParameter.TextAlignment.value ? ThemeService.shared.activeColor : UIColor.label }
    }
    
    // MARK: - IBActions
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        TapticEngine.selection.feedback()
        delegate?.didChangeValue(value: Int(sender.value), for: .FontSize, from: self)
    }
    
    @IBAction private func weightButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        fontWeightLabels.enumerated().forEach { $0.element.textColor = $0.offset == sender.tag ? ThemeService.shared.activeColor : UIColor.label }
        delegate?.didChangeValue(value: Int(sender.tag), for: .FontWeight, from: self)
    }
    
    @IBAction private func alignmentButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        alignmentImageViews.enumerated().forEach { $0.element.tintColor = $0.offset == sender.tag ? ThemeService.shared.activeColor : UIColor.label }
        delegate?.didChangeValue(value: Int(sender.tag), for: .TextAlignment, from: self)
    }
}
