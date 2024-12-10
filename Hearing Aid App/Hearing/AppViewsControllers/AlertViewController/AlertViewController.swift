import UIKit

protocol AlertViewControllerDelegate: AnyObject {
    func onConfirmButtonAction()
}

class AlertViewController: UIViewController {
    
    // MARK: - Private Properties
    private weak var delegate: AlertViewControllerDelegate?
    private let messageText: String
    private let dismissText: String?
    private let confirmText: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var dismissLabel: UILabel!
    
    // MARK: - Init
    init(messageText: String, dismissText: String?, confirmText: String?, delegate: AlertViewControllerDelegate?) {
        self.messageText = messageText
        self.dismissText = dismissText
        self.confirmText = confirmText
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
    
    // MARK: - Private methods
    private func configureUI() {
        messageLabel.text = messageText
        dismissLabel.text = dismissText
        confirmLabel.text = confirmText
    }
    
    // MARK: - Actions
    @IBAction func onCloseButtonAction(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func onDissmisButtonAction(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func onConfirmButtonAction(_ sender: Any) {
        delegate?.onConfirmButtonAction()
        dismiss(animated: false)
    }
}
