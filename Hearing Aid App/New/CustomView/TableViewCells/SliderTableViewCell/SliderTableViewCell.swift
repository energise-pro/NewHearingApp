import UIKit

protocol SliderTableViewCellDelegate: AnyObject {
    func didChangeSliderValue(on value: Float, from cell: SliderTableViewCell)
}

struct SliderTableViewCellModel {
    var title: String
    var sliderValue: Float
    var minSliderValue: Float = 0.0
    var maxSliderValue: Float = 1.0
    var topInset: CGFloat = 0.0
    weak var delegate: SliderTableViewCellDelegate?
}

typealias SliderTableViewCellConfig = ViewCellConfigurator<SliderTableViewCell, SliderTableViewCellModel>

final class SliderTableViewCell: UITableViewCell, ConfigurableCellProtocol, UIViewCellNib {

    typealias DataType = SliderTableViewCellModel
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var mainSlider: UISlider!
    
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var containerViewTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: SliderTableViewCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme), name: ThemeDidChangeNotificationName, object: nil)
        
        separatorView.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        
        didChangeTheme()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerViewTopConstraint.constant = .zero
        mainSlider.minimumValue = 0.0
        mainSlider.maximumValue = 1.0
    }
    
    func configure(data: DataType) {
        delegate = data.delegate
        titleLabel.text = data.title
        mainSlider.minimumValue = data.minSliderValue
        mainSlider.maximumValue = data.maxSliderValue
        mainSlider.value = data.sliderValue
        containerViewTopConstraint.constant = data.topInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    @objc private func didChangeTheme() {
        mainSlider.tintColor = ThemeService.shared.activeColor.withAlphaComponent(0.7)
    }
    
    // MARK: - IBActions
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        TapticEngine.selection.feedback()
        delegate?.didChangeSliderValue(on: sender.value, from: self)
    }
}
