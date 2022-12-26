//
//  HearingAidViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

final class HearingAidViewController: UIViewController {

    // MARK: - Public Properties
    var isVolumeViewConfigured = false
    
    // MARK: - Private Properties
    @IBOutlet private weak var primaryButton: RoundedButton!
    @IBOutlet private weak var buttonSubtitleLabel: UILabel!
    @IBOutlet private weak var outputImageView: UIImageView!
    @IBOutlet private weak var outputNameLabel: UILabel!
    @IBOutlet private weak var leftSliderLabel: UILabel!
    @IBOutlet private weak var rightSliderLabel: UILabel!
    @IBOutlet private weak var volumePercentageLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var sliderBackgroundView: UIView!
    @IBOutlet private weak var sliderFillView: UIView!
    @IBOutlet private weak var sliderContainerView: UIView!
    @IBOutlet private weak var sliderFillLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sliderFillRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var volumeContainerView: UIView!
    @IBOutlet private weak var volumeScaleContainerView: RoundedView!
    @IBOutlet private weak var volumePercentageContainerView: RoundedView!
    @IBOutlet private weak var volumeFillContainerView: RoundedView!
    @IBOutlet private weak var volumeScaleStackView: UIStackView!
    @IBOutlet private weak var volumePercentageContainerViewBottomConstraint: NSLayoutConstraint!
    private var presenter: HearingAidPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presenter.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }
    
    // MARK: - Private Methods
    @IBAction private func didChangeSliderValue(_ sender: UISlider) {
        presenter.didChangeBalanceSliderValue(to: Double(sender.value).rounded(toPlaces: 2))
    }
    
    @IBAction private func didTapPrimaryButton() {
        presenter.didTapPrimaryButton()
    }
    
    @IBAction private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: volumeContainerView)
        let percentage = 100 - (location.y / volumeContainerView.bounds.height) * 100
        presenter.didChangeVolumeSliderPercentage(to: percentage)
    }
}

// MARK: - HearingAidView
extension HearingAidViewController: HearingAidView {

    func setPresenter(_ presenter: HearingAidPresenterProtocol) {
        self.presenter = presenter
    }

    func layoutIfNeeded() {
        view.layoutIfNeeded()
    }
    
    func configureLocalization() {
        leftSliderLabel.text = presenter.leftSliderLabelTitle
        rightSliderLabel.text = presenter.rightSliderLabelTitle
        primaryButton.setTitle(presenter.primaryButtonTitle, for: .normal)
        buttonSubtitleLabel.text = presenter.buttonSubtitle
    }
    
    func setTitleForOutputDeviceLabel(_ title: String) {
        outputImageView.isHidden = title.isEmpty
        outputNameLabel.isHidden = title.isEmpty
        outputNameLabel.text = title
    }
    
    func configureForWorknigState(_ isWorking: Bool) {
        [volumeContainerView, slider].forEach { $0?.isUserInteractionEnabled = isWorking }
        primaryButton.setTitle(presenter.primaryButtonTitle, for: .normal)
        buttonSubtitleLabel.text = presenter.buttonSubtitle
        slider.value = presenter.sliderValue
    }
    
    func configureSliderFillView(for value: Double) {
        [sliderFillLeftConstraint, sliderFillRightConstraint].forEach { $0?.constant = 0 }
        if value > 0 {
            let widthMultiplier = (sliderBackgroundView.frame.width / 2) / CGFloat(abs(slider.maximumValue))
            sliderFillRightConstraint.constant = CGFloat(value) * widthMultiplier
        } else if value < 0 {
            let widthMultiplier = (sliderBackgroundView.frame.width / 2) / CGFloat(abs(slider.minimumValue))
            sliderFillLeftConstraint.constant = CGFloat(value) * widthMultiplier
        }
    }
    
    func configureVolumePercentageView(for value: Double) {
        volumePercentageLabel.text = "\(Int(value))%"
        let pathLenght = volumeContainerView.bounds.height - volumePercentageContainerView.bounds.height
        let constraintValue = (pathLenght * value) / 100.0
        let volumePercentageOffsetY = volumeContainerView.bounds.height - volumePercentageContainerView.bounds.height - constraintValue
        volumePercentageContainerViewBottomConstraint.constant = constraintValue
        for view in volumeScaleStackView.arrangedSubviews {
            let isUnderPersentageView = (view.frame.origin.y + volumeScaleStackView.frame.origin.y) > volumePercentageOffsetY
            view.backgroundColor = isUnderPersentageView ? .white : .secondaryLabel
        }
    }
    
    func configureScaleStackView(for value: Double) {
        volumeScaleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let heightBetweenView = 6.5
        let countOfViews = Int(volumeScaleStackView.bounds.height / heightBetweenView)
        let pathLenght = volumeContainerView.bounds.height - volumePercentageContainerView.bounds.height
        let constraintValue = (pathLenght * value) / 100.0
        let volumePercentageOffsetY = volumeContainerView.bounds.height - volumePercentageContainerView.bounds.height - constraintValue
        var scaleOffsetY = Double(volumeScaleStackView.frame.origin.y)
        (0..<countOfViews).forEach { index in
            scaleOffsetY += heightBetweenView
            let viewWidth = index == 0 || index == countOfViews - 1 || (index % 5 == 0) ? volumeScaleStackView.bounds.width : volumeScaleStackView.bounds.width * 0.7
            let view = UIView()
            view.backgroundColor = scaleOffsetY > volumePercentageOffsetY ? .white : .secondaryLabel
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 1.5),
                view.widthAnchor.constraint(equalToConstant: viewWidth)
            ])
            volumeScaleStackView.addArrangedSubview(view)
        }
    }
}
