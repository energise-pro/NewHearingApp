import UIKit

protocol TranscriptDetailsViewControllerDelegate: AnyObject {
    func didUpdateTranscript()
}

final class TranscriptDetailsViewController: PMUMainViewController {

    @IBOutlet private weak var mainTextView: UITextView!
    
    private weak var delegate: TranscriptDetailsViewControllerDelegate?
    private let transcriptModel: TranscribeModel
    private let transcriptModelIndex: Int?
    
    // MARK: - Init
    init(transcriptModel: TranscribeModel, delegate: TranscriptDetailsViewControllerDelegate?) {
        self.transcriptModel = transcriptModel
        self.transcriptModelIndex = TranscribeService.shared.savedTranscripts.firstIndex(where: { $0.title == transcriptModel.title })
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
            TranscribeService.shared.savedTranscripts.remove(at: index)
            delegate?.didUpdateTranscript()
        } else if transcriptModel.title != mainTextView.text {
            TranscribeService.shared.savedTranscripts[index] = TranscribeModel(title: mainTextView.text, createdDate: Date().timeIntervalSince1970)
            delegate?.didUpdateTranscript()
        }
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItems?.forEach { $0.tintColor = ThemeService.shared.activeColor }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Edit".localized()
        let shareButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonAction))
        let trashButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(trashButtonAction))
        navigationItem.rightBarButtonItems = [trashButtonItem, shareButtonItem]
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        mainTextView.text = transcriptModel.title
        mainTextView.tintColor = ThemeService.shared.activeColor
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
        
        AppConfiguration.shared.analytics.track(action: .v2TranscriptDetailsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.share.rawValue])
    }
    
    @objc private func trashButtonAction() {
        TapticEngine.impact.feedback(.medium)
        let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] _ in
            if let index = self?.transcriptModelIndex {
                TranscribeService.shared.savedTranscripts.remove(at: index)
                self?.delegate?.didUpdateTranscript()
                
                AppConfiguration.shared.analytics.track(action: .v2TranscriptDetailsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.delete.rawValue])
            }
            self?.navigationController?.popViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "No".localized(), style: .default)
        presentAlertPM(title: "Do you want to remove this transcript?".localized(), message: "", actions: [noAction, yesAction])
    }
}
