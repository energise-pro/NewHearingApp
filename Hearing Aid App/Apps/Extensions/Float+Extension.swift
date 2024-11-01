import Foundation

extension Float {
    func round1Decimal() -> Float {
        return Float(String(format: "%.1f", self)) ?? self
    }
    
    func string(_ isFractionEnabled:Bool) -> String {
        let format = isFractionEnabled ? "%.1f" : "%.f"
        return String(format: format, self)
    }
    
    var isInt: Bool {
        return truncatingRemainder(dividingBy: 1) == 0
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
