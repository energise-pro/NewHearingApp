//
//  OnboardingCollectionViewCell.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 08.12.2022.
//

import UIKit

final class OnboardingCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties
    @IBOutlet private weak var mainImageView: CroppedImageView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var preTitleLabel: UILabel!
    @IBOutlet private weak var preSubtitleLabel: UILabel!
    @IBOutlet private var infoTitlesLabels: [UILabel]!
    @IBOutlet private var infoSubtitlesLabels: [UILabel]!
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var reviewImagesStackView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Public Methods
    func configure(for screen: OnboardingScreen, numberOfScreens: Int) {
        mainImageView.image = screen.image
        pageControl.currentPage = screen.index
        titleLabel.text = screen.title
        subtitleLabel.text = screen.subtitle
        pageControl.numberOfPages = numberOfScreens
    }
    
    func configure(for screen: OnboardingScreen, price: String) {
        preTitleLabel.text = screen.title
        preSubtitleLabel.text = String(format: screen.subtitle, price)
        [mainImageView, containerView].forEach { $0?.isHidden = true }
        (infoTitlesLabels + infoSubtitlesLabels + [reviewImagesStackView, preTitleLabel, preSubtitleLabel, gradientView]).forEach { $0?.isHidden = false }
        let daysInfo = [
            "Today": "Start your full access to all blocking filters for Safari browser",
            "Day 2 your free trial": "Get a reminder about when your wrial will end",
            "Last day of trial": "Your free trial will end, you can renew if you want get full access"
        ]
        for (index, key) in daysInfo.keys.enumerated() {
            infoTitlesLabels[index].text = key.localized
            infoSubtitlesLabels[index].text = daysInfo[key]?.localized
        }
    }
}
