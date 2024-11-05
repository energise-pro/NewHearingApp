import UIKit

protocol HTexParamTableViewCellDelegate: AnyObject {
    func didChangeValue(value: Int, for parameter: GTranscribTextParam, from cell: HTexParamTableViewCell)
}

struct HTexParamTableViewCellModel {
    weak var delegate: HTexParamTableViewCellDelegate?
}

typealias HTexParamTableViewCellConfig = АViewCellConfig<HTexParamTableViewCell, HTexParamTableViewCellModel>

final class HTexParamTableViewCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = HTexParamTableViewCellModel
    
    // MARK: - Properties
    @IBOutlet private weak var fontSizeTitleLabel: UILabel!
    @IBOutlet private weak var fontWeightTitleLabel: UILabel!
    @IBOutlet private weak var alignmentTitleLabel: UILabel!
    
    @IBOutlet private weak var fontSizeSlider: UISlider!
    
    @IBOutlet private var fontWeightLabels: [UILabel]!
    
    @IBOutlet private var alignmentImageViews: [UIImageView]!
    
    private weak var delegate: HTexParamTableViewCellDelegate?
    
    // MARK: - Lifecycle
    func configure(data: DataType) {
        delegate = data.delegate
        configureUI()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        fontSizeTitleLabel.text = GTranscribTextParam.FontSize.title
        fontWeightTitleLabel.text = GTranscribTextParam.FontWeight.title
        alignmentTitleLabel.text = GTranscribTextParam.TextAlignment.title
        
        fontSizeSlider.tintColor = AThemeServicesAp.shared.activeColor.withAlphaComponent(0.7)
        
        fontSizeSlider.minimumValue = Float(GTranscribTextParam.FontSize.minValue)
        fontSizeSlider.maximumValue = Float(GTranscribTextParam.FontSize.maxValue)
        fontSizeSlider.value = Float(GTranscribTextParam.FontSize.value)
        
        fontWeightLabels.enumerated().forEach { $0.element.textColor = $0.offset == GTranscribTextParam.FontWeight.value ? AThemeServicesAp.shared.activeColor : UIColor.label }
        
        alignmentImageViews.enumerated().forEach { $0.element.tintColor = $0.offset == GTranscribTextParam.TextAlignment.value ? AThemeServicesAp.shared.activeColor : UIColor.label }
    }
    
    // MARK: - IBActions
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        TapticEngine.selection.feedback()
        delegate?.didChangeValue(value: Int(sender.value), for: .FontSize, from: self)
    }
    
    @IBAction private func weightButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        fontWeightLabels.enumerated().forEach { $0.element.textColor = $0.offset == sender.tag ? AThemeServicesAp.shared.activeColor : UIColor.label }
        delegate?.didChangeValue(value: Int(sender.tag), for: .FontWeight, from: self)
    }
    
    @IBAction private func alignmentButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        alignmentImageViews.enumerated().forEach { $0.element.tintColor = $0.offset == sender.tag ? AThemeServicesAp.shared.activeColor : UIColor.label }
        delegate?.didChangeValue(value: Int(sender.tag), for: .TextAlignment, from: self)
    }
}
