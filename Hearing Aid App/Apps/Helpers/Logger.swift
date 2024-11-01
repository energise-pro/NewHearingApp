import Foundation

final class Logger {
    
    private static let concurrentListenersQueue = DispatchQueue(label: "com.Logger.concurrentListenersQueue", qos: .background, attributes: .concurrent)
    private static var masterTag = "HearingAid__"
    private static var debugMode = false
    
    private static var logsAudit: [String] = []
    
    /// Switch debug mode on/off.
    /// This does not affect Business logging.
    ///
    /// - Parameter debugMode: true to switch debug mode on
    static func setDebugMode(debugMode: Bool) {
        self.debugMode = debugMode
    }
    
    /// Specifies whether the logger is set to debug or not.
    ///
    /// - Returns: true if the logger is in debug mode, otherwise false
    static func getDebugMode() -> Bool {
        return debugMode
    }
    
    /// Sets the master tag.
    ///This is used as a prefix for all log messages, making the filtering easier.
    ///
    /// - Parameter masterTag: Master tag
    static func setMasterTag(masterTag: String) {
        self.masterTag = masterTag
    }
    
    /// Logs an info
    ///
    /// - Parameters:
    ///   - tag: Log tag
    ///   - message: Message to log
    static func log(tag: String, message: String) {
        let message = "\(masterTag)\(tag) - \(message)"
        appendAndPrint(message)
    }

    /// Logs an info
    ///
    /// - Parameters:
    ///   - sender: Log sender
    ///   - message: Message to lo
    static func log<T>(sender: T, message: String) {
        let message = "\(masterTag)\(String(describing: type(of: sender))) - \(message)"
        appendAndPrint(message)
    }
    
    /// Logs an error
    ///
    /// - Parameters:
    ///   - tag: Log tag
    ///   - error: Error to log
    static func error(tag: String, error: Error) {
        let errorMessage = "\(masterTag)\(tag) - \(error.localizedDescription)"
        appendAndPrint(errorMessage)
    }
  
    /// Logs an error
    ///
    /// - Parameters:
    ///   - tag: Log tag
    ///   - error: Error message to log
    static func error(tag: String, error: String) {
        let errorMessage = "\(masterTag)\(tag) - \(error)"
        appendAndPrint(errorMessage)
    }
    
    /// Logs an error
    ///
    /// - Parameters:
    ///   - sender: Log sender
    ///   - error: Error to log
    static func error<T>(sender: T, error: Error) {
        let errorMessage = "\(masterTag)\(String(describing: type(of: sender))) - \(error.localizedDescription)"
        appendAndPrint(errorMessage)
    }
    
    /// Logs an error
    ///
    /// - Parameters:
    ///   - sender: Log sender
    ///   - error: Error message to log
    static func error<T>(sender: T, error: String) {
        let errorMessage = "\(masterTag)\(String(describing: type(of: sender))) - \(error)"
        appendAndPrint(errorMessage)
    }
    
    /// Generates a String containing information about the device.
    ///
    /// - Returns: Device info string
    static func deviceInfo() -> String {
        return ""        //TODO
    }
    
    static func getLogsAudit() -> [String] {
        return concurrentListenersQueue.sync(execute: { logsAudit })
    }
    
    static func printMessage(_ message: Any) {
        #if DEBUG
        print(message)
        #endif
    }
    
    static func destroy() {
        concurrentListenersQueue.async(flags: .barrier) {
            logsAudit.removeAll()
        }
    }
    
    // MARK: - Private methods
    private static func appendAndPrint(_ message: String) {
        concurrentListenersQueue.async(flags: .barrier) {
            printMessage(message)
        }
    }
}
