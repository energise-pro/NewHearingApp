import UIKit

final class SFakSplasApViewController: PMUMainViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        EApphudServiceAp.shared.loadABTestParams {
            DispatchQueue.main.async {
                AppsNavManager.shared.setOnboardingAsRootViewController()
            }
        }
    }
}
