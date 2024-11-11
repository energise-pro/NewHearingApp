//
//  NewOnboardPageCollectionViewCell.swift
//  Hearing Aid App
//
//

import UIKit

final class NewOnboardPageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Functions
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(model: NewOnbordingPageModelCollectionViewCell) {
        imageView.image = model.onboardingType.mainImage
    }
}
