//
//  HeadphonesConnectionViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class HeadphonesConnectionViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var imageView: CroppedImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var airplayButtonTitleLabel: UILabel!
    @IBOutlet private weak var getStartedButton: RoundedButton!
    private var presenter: HeadphonesConnectionPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapGetStartedButton() {
        presenter.didTapGetStartedButton()
    }
}

// MARK: - HeadphonesConnectionView
extension HeadphonesConnectionViewController: HeadphonesConnectionView {    
    
    func setPresenter(_ presenter: HeadphonesConnectionPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureUI() {
        imageView.image = UIImage(named: "airpods-in-hand")
    }
    
    func configureLocalization() {
        titleLabel.text = "Hello!".localized
        subtitleLabel.text = "Please connect your headphones for correctly hearing aid work".localized
        airplayButtonTitleLabel.text = "Select playback device".localized
        getStartedButton.setTitle("Get started".localized, for: .normal)
    }
}
