//
//  SettingsViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelSubscriptionButton: UIButton!
    @IBOutlet private weak var restorePurchaseButton: UIButton!
    @IBOutlet private weak var supportAndContactUsButton: UIButton!
    private var presenter: SettingsPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapCancelSubscriptionButton() {
        presenter.didTapCancelSubscriptionButton()
    }
    
    @IBAction private func didTapRestorePurchaseButton() {
        presenter.didTapRestorePurchaseButton()
    }
    
    @IBAction private func didTapSupportAndContactUsButton() {
        presenter.didTapSupportAndContactUsButton()
    }
}

// MARK: - SettingsView
extension SettingsViewController: SettingsView {
    
    func setPresenter(_ presenter: SettingsPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureLocalization() {
        titleLabel.text = presenter.title
        cancelSubscriptionButton.setTitle(presenter.cancelSubscriptionButtonTitle, for: .normal)
        restorePurchaseButton.setTitle(presenter.restorePurchaseButtonTitle, for: .normal)
        supportAndContactUsButton.setTitle(presenter.supportAndContactsUsButtonTitle, for: .normal)
    }
}
