import Foundation

final public class UserDefaultsStorage: NSObject {
    
    public static let shared = UserDefaultsStorage()
    
    public var specialOfferExpirationDate: Date? {
        get {
            if let timestamp = UserDefaults.standard.object(forKey: "SpecialOfferExpirationDate") as? TimeInterval {
                return Date(timeIntervalSince1970: timestamp)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "SpecialOfferExpirationDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "SpecialOfferExpirationDate")
            }
        }
    }
}
