import UIKit

protocol AlertViewControllerDelegate: AnyObject {
    func onConfirmButtonAction(isCheckboxSelected: Bool)
}

class AlertViewController: UIViewController {
    
    // MARK: - Private Properties
    private weak var delegate: AlertViewControllerDelegate?
    private let messageText: String
    private let dismissText: String?
    private let confirmText: String?
    private let checkboxText: String?
    
    private var isCheckboxSelected: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var dismissLabel: UILabel!
    @IBOutlet weak var checkboxContainer: UIView!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var bottomOffset: NSLayoutConstraint! // 73 - if need show checkbox view, else 24
    
    // MARK: - Init
    init(messageText: String, dismissText: String?, confirmText: String?, checkboxText: String? = nil, delegate: AlertViewControllerDelegate?) {
        self.messageText = messageText
        self.dismissText = dismissText
        self.confirmText = confirmText
        self.checkboxText = checkboxText
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
        if let checkboxText = checkboxText, !checkboxText.isEmpty {
            checkboxLabel.text = checkboxText
            checkboxImageView.image = isCheckboxSelected ? UIImage(named: "checkboxSelectedIcon") : UIImage(named: "checkboxNotSelectedIcon")
            checkboxContainer.isHidden = false
            bottomOffset.constant = 73
            view.updateConstraints()
        }
    }
    
    // MARK: - Actions
    @IBAction func onCloseButtonAction(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func onDissmisButtonAction(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func onConfirmButtonAction(_ sender: UIButton) {
        delegate?.onConfirmButtonAction(isCheckboxSelected: isCheckboxSelected)
        dismiss(animated: false)
    }
    
    @IBAction func onCheckboxButtonAction(_ sender: UIButton) {
        isCheckboxSelected = !isCheckboxSelected
        checkboxImageView.image = isCheckboxSelected ? UIImage(named: "checkboxSelectedIcon") : UIImage(named: "checkboxNotSelectedIcon")
    }
}
