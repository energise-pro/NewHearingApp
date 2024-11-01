import UIKit

struct OnboardingSpeechViewCellModel {
    
    var title = String()
    var description = String()
    var icon = UIImage()
    weak var delegate: OnboardingCollectionViewCellDelegate?
}
