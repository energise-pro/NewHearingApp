//
//  OnboardingViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class OnboardingViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var continueButton: RoundedButton!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var termsOfUseButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var activityIndicatorContainerView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private var presenter: OnboardingPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapContinueButton() {
        presenter.didTapContinueButton()
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
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OnboardingCollectionViewCell.self)
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfScreens
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        presenter.configure(cell: cell, for: indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OnboardingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - OnboardingView
extension OnboardingViewController: OnboardingView {
    
    func setPresenter(_ presenter: OnboardingPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureUI() {
        configureCollectionView()
    }
    
    func configureLocalization() {
        continueButton.setTitle("Continue".localized, for: .normal)
        privacyPolicyButton.setTitle("Privacy Policy".localized, for: .normal)
        termsOfUseButton.setTitle("Terms of use".localized, for: .normal)
        restoreButton.setTitle("Restore".localized, for: .normal)
    }
    
    func scrollToItem(at index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: true)
    }
    
    func setContinueButtonEnabled(_ isEnabled: Bool) {
        continueButton.isEnabled = isEnabled
    }
    
    func showCloseButton() {
        UIView.animate(withDuration: 0.3, delay: 3, options: [.allowUserInteraction]) {
            self.closeButton.alpha = 1
        }
    }
}
