//
//  PermissionsViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class PermissionsViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var allowButton: RoundedButton!
    private var presenter: PermissionPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapAllowButton() {
        presenter.didTapAllowButton()
    }
    
    @IBAction private func didTapCloseButton() {
        presenter.didTapCloseButton()
    }
}

// MARK: - PermissionsView
extension PermissionsViewController: PermissionsView {
    
    func setPresenter(_ presenter: PermissionPresenterProtocol) {
        self.presenter = presenter
    }

    func configureUI() {
        titleLabel.text = presenter.title
        subtitleLabel.text = presenter.subtitle
        imageView.image = presenter.image
    }
    
    func configureLocalization() {
        allowButton.setTitle("Allow".localized, for: .normal)
    }
}
