import Foundation
import ApphudSDK

typealias EApphudServiceApCompletion = (() -> Void)

enum ABTestType: String {
    case A_2
    case B_2
}

final class EApphudServiceAp {
    
    // MARK: - Properties
    static let shared: EApphudServiceAp = EApphudServiceAp()
    
    var abTestType: ABTestType {
        let testType = experimentPaywall?.variationName ?? ""
        return ABTestType(rawValue: testType) ?? .A_2
    }
    
    var experimentProducts: [ApphudProduct] {
        return experimentPaywall?.products ?? []
    }
    
    private var experimentPaywall: ApphudPaywall?
    
    // MARK: - Methods
    @MainActor
    func loadABTestParams(completion: @escaping EApphudServiceApCompletion) {
        Apphud.fetchPlacements {[weak self] placements, error in
            guard let placement = placements.first(where: { $0.identifier == "plc" }), let paywall = placement.paywall  else {
                completion()
                return
            }
            self?.experimentPaywall = paywall
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
