import Foundation
import ApphudSDK

typealias AppHudServiceCompletion = (() -> Void)

enum ABTestType: String {
    case A_2
    case B_2
}

final class AppHudService {
    
    // MARK: - Properties
    static let shared: AppHudService = AppHudService()
    
    var abTestType: ABTestType {
        let testType = experimentPaywall?.variationName ?? ""
        return ABTestType(rawValue: testType) ?? .A_2
    }
    
    var experimentProducts: [ApphudProduct] {
        let groupProducts = Apphud.permissionGroups.first(where: { $0.name == InAppPurchasesService.GroupType.subscriptions.rawValue })?.products ?? []
        return experimentPaywall?.products ?? groupProducts
    }
    
    private var experimentPaywall: ApphudPaywall?
    
    // MARK: - Methods
    func loadABTestParams(completion: @escaping AppHudServiceCompletion) {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let experimentPaywall = paywalls.first(where: { $0.experimentName != nil }) else {
                completion()
                return
            }
            self?.experimentPaywall = experimentPaywall
            completion()
        }
    }
    
    func paywallShown() {
        guard let experimentPaywall = experimentPaywall else {
            return
        }
        Apphud.paywallShown(experimentPaywall)
    }
    
    func paywallClosed() {
        guard let experimentPaywall = experimentPaywall else {
            return
        }
        Apphud.paywallClosed(experimentPaywall)
    }
}
