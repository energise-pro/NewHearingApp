//
//  PaywallViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class PaywallViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var productCardsStackView: UIStackView!
    @IBOutlet private var productTrialLabels: [UILabel]!
    @IBOutlet private var productNameLabels: [UILabel]!
    @IBOutlet private var productPriceLabels: [UILabel]!
    @IBOutlet private weak var mainSubscriptionProfilLabel: UILabel!
    @IBOutlet private weak var mainSubscriptionHeaderLabel: RoundedLabel!
    @IBOutlet private weak var subscribeButton: UIButton!
    @IBOutlet private var infoTitleLabels: [UILabel]!
    @IBOutlet private var infoSubtitleLabels: [UILabel]!
    @IBOutlet private weak var switchControl: UISwitch!
    @IBOutlet private weak var switchControlTitleLabel: UILabel!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var termsOfUseButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    private var presenter: PaywallPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapProductButton(_ sender: UIButton) {
        presenter.didTapProductButton(at: sender.tag)
    }
    
    @IBAction private func didChangeSwitchState(_ sender: UISwitch) {
        presenter.didChangeSwitchState(sender.isOn)
    }
    
    @IBAction private func didTapSubscribeButton() {
        presenter.didTapSubscribeButton()
    }
    
    @IBAction private func didTapPrivacyPolicyButton() {
        presenter.didTapPrivacyPolicyButton()
    }
    
    @IBAction private func didTapTermsOfUseButton() {
        presenter.didTapTermsOfUseButton()
    }
    
    @IBAction private func didTapRestoreButton() {
        presenter.didTapRestoreButton()
    }
    
    @IBAction private func didTapCloseButton() {
        presenter.didTapCloseButton()
    }
}

// MARK: - PaywallView
extension PaywallViewController: PaywallView {
    
    func setPresenter(_ presenter: PaywallPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureLocalization() {
        mainSubscriptionHeaderLabel.text = presenter.mainProductHeaderLabelTitle
        productTrialLabels.forEach { $0.attributedText = presenter.trialLabelTitle }
        if !presenter.productsNames.isEmpty, !presenter.productsPrices.isEmpty {
            productNameLabels.enumerated().forEach { $1.text = presenter.productsNames[$0] }
            productPriceLabels.enumerated().forEach { $1.text = presenter.productsPrices[$0] }
        }
        if let profitTitle = presenter.profitTitle {
            mainSubscriptionProfilLabel.text = profitTitle
            mainSubscriptionProfilLabel.isHidden = false
        }
        infoTitleLabels.enumerated().forEach { $1.text = presenter.infoTitles[$0] }
        infoSubtitleLabels.enumerated().forEach { $1.text = presenter.infoSubtitles[$0] }
        switchControlTitleLabel.text = presenter.switchControlTitle
        subscribeButton.setTitle(presenter.subscribeButtonTitle, for: .normal)
        privacyPolicyButton.setTitle(presenter.privacyPolicyButtonTitle, for: .normal)
        termsOfUseButton.setTitle(presenter.termsOfUseButtonTitle, for: .normal)
        restoreButton.setTitle(presenter.restoreButtonTitle, for: .normal)
    }
    
    func setSelectedProductView(at index: Int) {
        productCardsStackView.arrangedSubviews.forEach { ($0 as? RoundedView)?.borderWidth = 1.5 }
        (productCardsStackView.arrangedSubviews[index] as? RoundedView)?.borderWidth = 4.0
    }
    
    func setProductTrialLabelsHidden(_ isHidden: Bool) {
        productTrialLabels.forEach { $0.isHidden = isHidden }
    }
    
    func setSwitchControlEnabled(_ isEnabled: Bool) {
        switchControl.isOn = isEnabled
        switchControl.isUserInteractionEnabled = isEnabled
    }
    
    func setProductCardsHidden(_ isHidden: Bool) {
        productCardsStackView.isHidden = isHidden
        mainSubscriptionHeaderLabel.isHidden = isHidden
    }
}
