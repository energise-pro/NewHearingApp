//
//  SpeechRecognitionViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class SpeechRecognitionViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var languageButton: UIButton!
    @IBOutlet private weak var microButtonHeaderLabel: UILabel!
    @IBOutlet private weak var microButton: UIButton!
    @IBOutlet private weak var logoContainerView: UIView!
    @IBOutlet private weak var textView: UITextView!
    private var presenter: SpeechRecognitionPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        languageButton.alignTextBelow()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapChangeLanguageButton() {
        presenter.didTapChangeLanguageButton()
    }
    
    @IBAction private func didTapMicroButton() {
        presenter.didTapMicroButton()
    }
}

// MARK: - SpeechRecognitionView
extension SpeechRecognitionViewController: SpeechRecognitionView {
    
    func setPresenter(_ presenter: SpeechRecognitionPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureUIForWorkingState(_ isWorking: Bool) {
        languageButton.setTitle(presenter.currentLanguage, for: .normal)
        languageButton.alignTextBelow()
        microButtonHeaderLabel.isHidden = isWorking
        microButton.tintColor = isWorking ? .accentColor : .primaryLabel
        logoContainerView.isHidden = isWorking
        textView.isHidden = !isWorking
        textView.contentScaleFactor = 0.5
    }
    
    func configureLocalization() {
        microButtonHeaderLabel.text = "Tap the mic to get started".localized
    }
    
    func setTextForTextView(_ text: String) {
        textView.text = text
    }
}

public extension UIButton {

    func alignTextBelow(spacing: CGFloat = 6.0) {
        guard let image = imageView?.image else { return }
        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
        let labelString = NSString(string: titleLabel!.text!)
        let titleSize = labelString.size(withAttributes: [.font: titleLabel!.font!])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
}
