import UIKit

protocol YTranscriptDetailApViewControllerDelegate: AnyObject {
    func didUpdateTranscript()
}

final class YTranscriptDetailApViewController: PMUMainViewController {

    @IBOutlet private weak var mainTextView: UITextView!
    
    private weak var delegate: YTranscriptDetailApViewControllerDelegate?
    private let transcriptModel: TranscribeModel
    private let transcriptModelIndex: Int?
    
    // MARK: - Init
    init(transcriptModel: TranscribeModel, delegate: YTranscriptDetailApViewControllerDelegate?) {
        self.transcriptModel = transcriptModel
        self.transcriptModelIndex = CTranscribServicesAp.shared.savedTranscripts.firstIndex(where: { $0.title == transcriptModel.title })
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let index = transcriptModelIndex else {
            return
        }
        if mainTextView.text.isEmpty {
            CTranscribServicesAp.shared.savedTranscripts.remove(at: index)
            delegate?.didUpdateTranscript()
        } else if transcriptModel.title != mainTextView.text {
            CTranscribServicesAp.shared.savedTranscripts[index] = TranscribeModel(title: mainTextView.text, createdDate: Date().timeIntervalSince1970)
            delegate?.didUpdateTranscript()
        }
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
//        navigationItem.leftBarButtonItems?.forEach { $0.tintColor = AThemeServicesAp.shared.activeColor }
//        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Edit".localized()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        let shareButtonItem = UIBarButtonItem(image: UIImage(named: "shareButtonIcon"), style: .plain, target: self, action: #selector(shareButtonAction))
        let trashButtonItem = UIBarButtonItem(image:  UIImage(named: "trashIcon"), style: .plain, target: self, action: #selector(trashButtonAction))
        navigationItem.leftBarButtonItems = [shareButtonItem, trashButtonItem]
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        setupRightBarButton()
        
        mainTextView.text = transcriptModel.title
        mainTextView.tintColor = UIColor.appColor(.Purple70)
    }
    
    private func setupRightBarButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close".localized(), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.setTitleColor(UIColor.appColor(.Red100), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    // MARK: - Actions
    @objc private func shareButtonAction() {
        TapticEngine.impact.feedback(.medium)
        var shareText: String
        if let text = mainTextView.text, !text.isEmpty {
            shareText = text
        } else {
            shareText = "Try this app!".localized() + "🙂"
        }
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(CAppConstants.URLs.appStoreUrl)"
        AppsNavManager.shared.presentShareViewController(with: [shareText], and: mainTextView.inputAccessoryView)
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscriptDetailsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.share.rawValue])
    }
    
    @objc private func trashButtonAction() {
        TapticEngine.impact.feedback(.medium)
        presentCustomAlert(
            withMessageText: "Delete this transcript?".localized(),
            dismissButtonText: "Keep".localized(),
            confirmButtonText: "Delete".localized(),
            delegate: self
        )
    }
    
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
//        KAppConfigServic.shared.analytics.track(action: .v2VoiceChangerScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
}

// MARK: - AlertViewControllerDelegate
extension YTranscriptDetailApViewController: AlertViewControllerDelegate {
    
    func onConfirmButtonAction(isCheckboxSelected: Bool) {
        if let index = transcriptModelIndex {
            CTranscribServicesAp.shared.savedTranscripts.remove(at: index)
            delegate?.didUpdateTranscript()
            
            KAppConfigServic.shared.analytics.track(action: .v2TranscriptDetailsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.delete.rawValue])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
