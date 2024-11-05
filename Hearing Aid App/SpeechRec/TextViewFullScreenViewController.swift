import UIKit

protocol RTextVFullScrViewControllerDelegate: AnyObject {
    func didExitFullScreen()
}

final class RTextVFullScrViewController: UMainViewController {
    @IBOutlet weak var textView: TextView!
    @IBOutlet weak var fullScreenButton: ButtonView!

    var text: String = "" {
        didSet {
            if isViewLoaded {
                textView.text = text
            }
        }
    }

    var transform: CGAffineTransform? {
        didSet {
            if isViewLoaded, let transform = transform {
                textView.transform = transform
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenButton.isSelected = true
        textView.text = text
        if let transform = transform {
            textView.transform = transform
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        textView.scrollToBottom()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    weak var delegate: RTextVFullScrViewControllerDelegate?

    @IBAction func fullScreenAction(sender: UIButton) {
        delegate?.didExitFullScreen()
        dismiss(animated: true, completion: nil)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        let isShakeToClearEnabled = SpeechRecognitionSettings.ShakeToClearText.value as? Bool ?? false
        if motion == .motionShake && isShakeToClearEnabled {
            let parent = (presentingViewController as? HomeTabBarController)?.viewControllers?.compactMap({ $0 as? USpeechRecViewController}).first
            parent?.clearTextAction(sender: nil)
        }
    }
}
