import UIKit

final class FakeSplashViewController: PMBaseViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppHudService.shared.loadABTestParams {
            DispatchQueue.main.async {
                NavigationManager.shared.setOnboardingAsRootViewController()
            }
        }
    }
}
