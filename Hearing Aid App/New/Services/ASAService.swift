import UIKit
import AdSupport
import AppTrackingTransparency
import ApphudSDK
import AdServices
import ASATools
import Amplitude
//import iAd

typealias ASAServiceCompletion = () -> ()

final class ASAService {
    
    // MARK: - Properties
    static let TAG = "ASAService"
    
    private var IDFA: String = ""
    
    // MARK: - Internal methods
    func requestIDFA(completion: ASAServiceCompletion?) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                completion?()
                let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : "00000000-0000-0000-0000-000000000000"
                self?.IDFA = idfa
                status == .authorized ? Apphud.setAdvertisingIdentifier(idfa) : Void()
            }
        } else {
            completion?()
            IDFA = "00000000-0000-0000-0000-000000000000"
        }
    }
    
    func initializeASATools() {
        ASATools.instance.attribute(apiToken: Constants.General.asaToolsKey) { response, error in
            if let response = response {
                // store response.analyticsValues() in your product analytics
                Amplitude.instance().setUserProperties(response.analyticsValues())
                Amplitude.instance().logEvent("did_receive_asa_attribution", withEventProperties: response.analyticsValues())
            }
        }
    }
    
    func sendAppleAttribution() {
        guard !UserDefaults.standard.bool(forKey: Constants.Keys.needsSkipSearchAdsTracking) else { return }
        
        if #available(iOS 14.3, *) {
            DispatchQueue.global(qos: .default).async { [weak self] in
                if let token = try? AAAttribution.attributionToken() {
                    DispatchQueue.main.async {
                        Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: token, callback: nil)
                    }
                    self?.sendASAInfo(with: ["token_info": token])
                } else {
                    self?.sendASAInfo()
                }
            }
        } else {
            /*
            // optionally send Search Ads attribution data from older iOS versions
            ADClient.shared().requestAttributionDetails { [weak self] data, error in
                data.map { Apphud.addAttribution(data: $0, from: .appleSearchAds, callback: nil) }
                
                guard error == nil else {
                    self?.sendASAInfo()
                    return
                }
                            
                guard let versionKey = data?.keys.first(where: { $0.lowercased().contains("version") }) else {
                    self?.sendASAInfo()
                    return
                }
                
                guard let trackingAttributes = data?[versionKey] as? [String: Any],
                    let campaignId = trackingAttributes["iad-campaign-id"] as? String,
                    campaignId != "1234567890" else {
                    self?.sendASAInfo()
                    return
                }
                
                self?.sendASAInfo(with: trackingAttributes)
            }
            */
        }
    }
    
    // MARK: - Private methods
    private func sendASAInfo(with properties: [String: Any] = [:]) {
        if !UserDefaults.standard.bool(forKey: Constants.Keys.wasSentASAInstall) {
            UserDefaults.standard.setValue(!properties.isEmpty, forKey: Constants.Keys.needsSkipSearchAdsTracking)
            setAppInstall(searchAdAttributes: properties)
            setUserProperties(properties)
        } else {
            UserDefaults.standard.setValue(true, forKey: Constants.Keys.needsSkipSearchAdsTracking)
            setAppSearchAdsInfo(searchAdAttributes: properties)
            setUserProperties(properties)
        }
    }
    
    private func setUserProperties(_ properties: [String: Any]) {
        var allProperties: [String: Any] = [:]
        properties.forEach { (k,v) in allProperties[k] = v }
        
        allProperties["IDFA"] = IDFA
        
        AppConfiguration.shared.analytics.setUserProperty(with: allProperties)
    }
    
    private func setAppInstall(searchAdAttributes: [String: Any]) {
        let version = "\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))"
        
        // prepare json data
        var jsonFields: [String: Any] = searchAdAttributes
        jsonFields["user_id"] = Apphud.userID()
        jsonFields["version"] = version
        jsonFields["os_version"] = UIDevice.current.systemVersion
        jsonFields["os_name"] = UIDevice.current.systemName
        jsonFields["device_name"] = UIDevice.current.name
        jsonFields["device_model"] = getDeviceModel()
        jsonFields["locale"] = Locale.current.identifier
        jsonFields["timezone"] = Calendar.current.timeZone.identifier
        jsonFields["_api_key"] = Constants.General.APIKey
        
        let url = URL(string: Constants.General.baseURL + "app_installs/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonFields)
        request.httpBody = jsonData
        
        Logger.log(tag: ASAService.TAG, message: "Set app install with data - \(jsonFields)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            UserDefaults.standard.setValue(true, forKey: Constants.Keys.wasSentASAInstall)
            
            guard let data = data, error == nil else {
                Logger.log(tag: ASAService.TAG, message: "Set app install failed with error - \(error?.localizedDescription ?? "")")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                Logger.log(tag: ASAService.TAG, message: "App install successfully recorded - \(responseJSON)")
            }
        }
        
        task.resume()
    }
    
    private func setAppSearchAdsInfo(searchAdAttributes: [String: Any]) {
        var jsonFields: [String: Any] = searchAdAttributes
        jsonFields["_api_key"] = Constants.General.APIKey
        jsonFields["user_id"] = Apphud.userID()
        
        // create post request
        let url = URL(string: Constants.General.baseURL +  "users/add_search_ads_info")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonFields)
        request.httpBody = jsonData
        
        Logger.log(tag: ASAService.TAG, message: "Set app search ads with data - \(jsonFields)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Logger.log(tag: ASAService.TAG, message: "Set app search ads failed with error - \(error?.localizedDescription ?? "")")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                Logger.log(tag: ASAService.TAG, message: "App search ads successfully recorded - \(responseJSON)")
            }
        }
        
        task.resume()
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
