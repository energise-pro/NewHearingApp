import Foundation

typealias SimpleJSON = [String : Any]

extension Encodable {
    
    func toData() throws -> Data {
        if let someData = self as? Data {
            return someData
        } else if let someString = self as? String, let stringData = someString.data(using: .utf8) {
            return stringData
        } else {
            return try JSONEncoder().encode(self)
        }
    }
    
    func toJSON() -> SimpleJSON? {
        do {
            let data = try toData()
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    func toString() -> String? {
        do {
            let data = try toData()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

extension Encodable where Self: LosslessStringConvertible {
    
    func toString() -> String? {
        return String(self)
    }
}

extension Decodable {
    
    static func decode(from data: Data?) -> Self? {
        guard let data = data else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(self, from: data)
        } catch {
            return nil
        }
    }
    
    static func decode(from json: SimpleJSON?) -> Self? {
        guard let json = json else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return decode(from: data)
        } catch {
            return nil
        }
    }
}
