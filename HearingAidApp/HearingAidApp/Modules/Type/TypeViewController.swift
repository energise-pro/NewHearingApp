//
//  TypeViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 23.12.2022.
//

import UIKit

final class TypeViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var resultTextLabel: UILabel!
    @IBOutlet private weak var primaryButton: UIButton!
    @IBOutlet private weak var textFieldContainerView: UIView!
    @IBOutlet private weak var textFieldContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textField: UITextField!
    private var presenter: TypePresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapPrimaryButton() {
        presenter.didTapPrimaryButton()
    }
    
    @IBAction private func didTapClearButton() {
        presenter.didTapClearButton()
    }
    
    @IBAction private func didTapFullSreenButton() {
        presenter.didTapFullScreenButton()
    }
    
    @IBAction private func textFieldTextDidChange(_ sender: UITextField) {
        presenter.didTypeText(sender.text)
    }
    
    private func configureTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        resultTextLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        presenter.didTapPrimaryButton()
    }
    
    private func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            textFieldContainerViewBottomConstraint.constant = keyboardFrame.cgRectValue.height
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide() {
        textFieldContainerViewBottomConstraint.constant = 0
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

// MARK: - TypeView
extension TypeViewController: TypeView {
    
    func setPresenter(_ presenter: TypePresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureUI() {
        configureTapGestures()
        configureKeyboardObservers()
    }
    
    func configureLocalization() {
        resultTextLabel.text = presenter.emptyStateText
    }
    
    func setInputHidden(_ isHidden: Bool) {
        primaryButton.isHidden = !isHidden
        textFieldContainerView.isHidden = isHidden
        resultTextLabel.text = textField.text?.isEmpty == true ? presenter.emptyStateText : textField.text!
        _ = isHidden ? textField.resignFirstResponder() : textField.becomeFirstResponder()
    }
    
    func setResultText(_ text: String) {
        resultTextLabel.text = text
    }
    
    func clearTextField() {
        textField.text = nil
        resultTextLabel.text = ""
    }
}

// MARK: - UITextFieldDelegate
extension TypeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setInputHidden(true)
        return true
    }
}
