import UIKit

final class TranscriptionInstructionViewController: UIViewController {
    // MARK: - Properties
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var transcriptionGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Transcription Guide".localized()
        label.textAlignment = .left
        label.textColor = UIColor.appColor(.Purple100)
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transcriptionGuideStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var transcriptionGuideCustomView: UIView = {
        let view = createCustomView(
            imageName: "speechTranscribeIcon",
            title: "Transcribe".localized(),
            description: "Transcribe speech into easy-to-read text in real time with superior accuracy.".localized()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var translationGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Translation Guide".localized()
        label.textAlignment = .left
        label.textColor = UIColor.appColor(.Purple100)
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var translationGuideStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var translationGuideCustomView: UIView = {
        let view = createCustomView(
            imageName: "speechTranslateIcon",
            title: "Translate".localized(),
            description: "Translate speech in real time, supporting 60+ languages offline.".localized()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var typeGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Type Guide".localized()
        label.textAlignment = .left
        label.textColor = UIColor.appColor(.Purple100)
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeGuideStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var typeGuideCustomView: UIView = {
        let view = createCustomView(
            imageName: "speechTypeIcon",
            title: "Type".localized(),
            description: "Type and display your text in a large, easy-to-read format for comfortable viewing.".localized()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiLoad()
    }
    
    // MARK: - Private methods
    private func uiLoad(){
        view.backgroundColor = UIColor.appColor(.Purple10)
        closeButton.setImage(UIImage(named: "closeBtns"), for: .normal)
        createElement()
        layoutElement()
    }
    
    private func createElement(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(closeButton)
        
        contentView.addSubview(transcriptionGuideTitleLabel)
        contentView.addSubview(transcriptionGuideStackView)
        let transcriptionGuideLabel1 = createLabelStep(withText: "1. Tap the Transcribe button to get started".localized())
        let transcriptionGuideLabel2 = createLabelStep(withText: "2. Speech turns into text in real time".localized())
        let transcriptionGuideLabel3 = createLabelStep(withText: "3. Adjust text size and save if needed".localized())
        transcriptionGuideStackView.addArrangedSubview(transcriptionGuideLabel1)
        transcriptionGuideStackView.addArrangedSubview(transcriptionGuideLabel2)
        transcriptionGuideStackView.addArrangedSubview(transcriptionGuideLabel3)
        contentView.addSubview(transcriptionGuideCustomView)
        
        contentView.addSubview(translationGuideTitleLabel)
        contentView.addSubview(translationGuideStackView)
        let translationGuideLabel1 = createLabelStep(withText: "1. Tap the Translate button to get started".localized())
        let translationGuideLabel2 = createLabelStep(withText: "2. Speech turns into text and translates into the chosen language in real time".localized())
        let translationGuideLabel3 = createLabelStep(withText: "3. Adjust text size and save if needed".localized())
        translationGuideStackView.addArrangedSubview(translationGuideLabel1)
        translationGuideStackView.addArrangedSubview(translationGuideLabel2)
        translationGuideStackView.addArrangedSubview(translationGuideLabel3)
        contentView.addSubview(translationGuideCustomView)
        
        contentView.addSubview(typeGuideTitleLabel)
        contentView.addSubview(typeGuideStackView)
        let typeGuideLabel1 = createLabelStep(withText: "1. Tap the Type button to get started".localized())
        let typeGuideLabel2 = createLabelStep(withText: "2. Enter text manually to display it in large, easy-to-read font".localized())
        let typeGuideLabel3 = createLabelStep(withText: "3. Hide the keyboard for easier reading".localized())
        typeGuideStackView.addArrangedSubview(typeGuideLabel1)
        typeGuideStackView.addArrangedSubview(typeGuideLabel2)
        typeGuideStackView.addArrangedSubview(typeGuideLabel3)
        contentView.addSubview(typeGuideCustomView)
    }
    
    private func layoutElement() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -2),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 68),
            closeButton.heightAnchor.constraint(equalToConstant: 68),
            
            transcriptionGuideTitleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: -2),
            transcriptionGuideTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transcriptionGuideTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            transcriptionGuideStackView.topAnchor.constraint(equalTo: transcriptionGuideTitleLabel.bottomAnchor, constant: 20),
            transcriptionGuideStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            transcriptionGuideStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            transcriptionGuideCustomView.topAnchor.constraint(equalTo: transcriptionGuideStackView.bottomAnchor, constant: 20),
            transcriptionGuideCustomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transcriptionGuideCustomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            translationGuideTitleLabel.topAnchor.constraint(equalTo: transcriptionGuideCustomView.bottomAnchor, constant: 44),
            translationGuideTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            translationGuideTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            translationGuideStackView.topAnchor.constraint(equalTo: translationGuideTitleLabel.bottomAnchor, constant: 20),
            translationGuideStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            translationGuideStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            translationGuideCustomView.topAnchor.constraint(equalTo: translationGuideStackView.bottomAnchor, constant: 20),
            translationGuideCustomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            translationGuideCustomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            typeGuideTitleLabel.topAnchor.constraint(equalTo: translationGuideCustomView.bottomAnchor, constant: 44),
            typeGuideTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeGuideTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            typeGuideStackView.topAnchor.constraint(equalTo: typeGuideTitleLabel.bottomAnchor, constant: 20),
            typeGuideStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeGuideStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            typeGuideCustomView.topAnchor.constraint(equalTo: typeGuideStackView.bottomAnchor, constant: 20),
            typeGuideCustomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeGuideCustomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            typeGuideCustomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createCustomView(imageName: String, title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 12
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        containerView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.23
        titleLabel.attributedText = NSMutableAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.appColor(.Purple100)!
            ]
        )
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = NSMutableAttributedString(
            string: description,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.appColor(.Purple70)!
            ]
        )
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 16),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor,constant: -16),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor,constant: -16)
        ])
        
        return containerView
    }
    
    private func createLabelStep(withText text: String) -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.23
        label.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.appColor(.Purple100)!
                        ]
        )
        return label
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        print("Close button tapped")
        self.dismiss(animated: true, completion: nil)
    }
}
