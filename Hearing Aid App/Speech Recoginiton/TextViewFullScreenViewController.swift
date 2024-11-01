import UIKit

protocol TextViewFullScreenViewControllerDelegate: AnyObject {
    func didExitFullScreen()
}

final class TextViewFullScreenViewController: BaseViewController {
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

    weak var delegate: TextViewFullScreenViewControllerDelegate?

    @IBAction func fullScreenAction(sender: UIButton) {
        delegate?.didExitFullScreen()
        dismiss(animated: true, completion: nil)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        let isShakeToClearEnabled = SpeechRecognitionSettings.ShakeToClearText.value as? Bool ?? false
        if motion == .motionShake && isShakeToClearEnabled {
            let parent = (presentingViewController as? TabBarController)?.viewControllers?.compactMap({ $0 as? SpeechRecognitionViewController}).first
            parent?.clearTextAction(sender: nil)
        }
    }
}
