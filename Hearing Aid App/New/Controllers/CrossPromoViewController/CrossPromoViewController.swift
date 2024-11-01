import UIKit

final class CrossPromoViewController: PMBaseViewController {

    // MARK: - Properties
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var continueButton: UIButton!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet private var featureLabels: [UILabel]!
    
    @IBOutlet private var tagViews: [UIView]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        AppConfiguration.shared.analytics.track(action: .v2CrossPromoScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layoutIfNeeded()
        continueButton.addGradient([UIColor.appColor(.ActiveColor_1)!, UIColor.appColor(.ActiveColor_2)!], isHorizontal: true)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        closeButton.tintColor = UIColor.black
        
        titleLabel.text = "Magnifying Glass & Loupe".localized()
        infoLabel.text = "Magnifying glass with high image quality and easy to use".localized()
        ["Magnifier 30X, pro features".localized(), "flashlight".localized(), "Reading filters & scan text".localized()].enumerated().forEach { featureLabels[$0.offset].text = $0.element }
        continueButton.setTitle("Try for free".localized(), for: .normal)
        
        tagViews.forEach {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.appColor(.ActiveColor_1)?.cgColor
            $0.layer.cornerRadius = 6.0
        }
    }
    
    // MARK: - IBActions
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
        
        AppConfiguration.shared.analytics.track(action: .v2CrossPromoScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
    
    @IBAction private func continueButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        UIApplication.shared.open(Constants.URLs.lupaAppStoreURL, options: [:], completionHandler: nil)
        
        AppConfiguration.shared.analytics.track(action: .v2CrossPromoScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.continue.rawValue])
    }
}
