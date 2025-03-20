import UIKit
import AdSupport
import AppTrackingTransparency
import ApphudSDK
import AdServices
import ASATools

typealias QAsaServiceApCompletion = () -> ()

final class QAsaServiceAp {
    
    // MARK: - Properties
    static let TAG = "QAsaServiceAp"
    
    private var IDFA: String = ""
    
    // MARK: - Internal methods
    func requestIDFA(completion: QAsaServiceApCompletion?) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                completion?()
                let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : "00000000-0000-0000-0000-000000000000"
                self?.IDFA = idfa
                status == .authorized ? Apphud.setDeviceIdentifiers(idfa: idfa, idfv: idfa) : Void()
                KAppConfigServic.shared.analytics.track(
                    action: .firstOpenApp,
                    with: [
                        "att_authorised" : status == .authorized
                    ]
                )
            }
        } else {
            completion?()
            IDFA = "00000000-0000-0000-0000-000000000000"
        }
    }
    
    func initializeASATools() {
        ASATools.instance.attribute(apiToken: CAppConstants.General.asaToolsKey) { response, error in
            if let response = response {
                // store response.analyticsValues() in your product analytics
                KAppConfigServic.shared.analytics.setUserProperty(with: response.analyticsValues())
                KAppConfigServic.shared.analytics.track(.didReceiveAsaAttribution, with: response.analyticsValues())
            }
        }
    }
    
    func initializeJaklinSDK() {
        OtterScale.shared.initialize(host: CAppConstants.General.otterScaleHost, apiKey: CAppConstants.General.otterScaleApiKey)
    }
    
//    func sendAppleAttribution() {
//        guard !UserDefaults.standard.bool(forKey: CAppConstants.Keys.needsSkipSearchAdsTracking) else { return }
//        
//        if #available(iOS 14.3, *) {
//            DispatchQueue.global(qos: .default).async { [weak self] in
//                if let token = try? AAAttribution.attributionToken() {
//                    DispatchQueue.main.async {
//                        Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: token, callback: nil)
//                    }
//                    self?.sendASAInfo(with: ["token_info": token])
//                } else {
//                    self?.sendASAInfo()
//                }
//            }
//        } 
//    }
    
    func sendAppleAttribution() {
        if #available(iOS 14.3, *) {
            Task {
                do {
                    let asaToken = try AAAttribution.attributionToken()
                    Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: asaToken, callback: nil)
                    KAppConfigServic.shared.analytics.setUserProperty(with: ["did_asa_Token": asaToken])
                    let isAttributed = !asaToken.isEmpty
                    let userTrafficType = isAttributed ? "attributed" : "organic"
                    KAppConfigServic.shared.analytics.setUserProperty(with: ["did_asa_att": userTrafficType])
                } catch {
                    let errorType = "asa_token_error"
                    KAppConfigServic.shared.analytics.setUserProperty(with: ["did_asa_att": errorType])
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func sendASAInfo(with properties: [String: Any] = [:]) {
        if !UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasSentASAInstall) {
            UserDefaults.standard.setValue(!properties.isEmpty, forKey: CAppConstants.Keys.needsSkipSearchAdsTracking)
            setUserProperties(properties)
        } else {
            UserDefaults.standard.setValue(true, forKey: CAppConstants.Keys.needsSkipSearchAdsTracking)
            setUserProperties(properties)
        }
    }
    
    private func setUserProperties(_ properties: [String: Any]) {
        var allProperties: [String: Any] = [:]
        properties.forEach { (k,v) in allProperties[k] = v }
        
        allProperties["IDFA"] = IDFA
        
        KAppConfigServic.shared.analytics.setUserProperty(with: allProperties)
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return UIDevice.current.mapToCommonDeviceName(identifier: identifier)
    }
}
