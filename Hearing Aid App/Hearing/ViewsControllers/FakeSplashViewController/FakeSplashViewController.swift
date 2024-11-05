import UIKit

final class FakeSplashViewController: PMUMainViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppHudService.shared.loadABTestParams {
            DispatchQueue.main.async {
                AppsNavManager.shared.setOnboardingAsRootViewController()
            }
        }
    }
}
