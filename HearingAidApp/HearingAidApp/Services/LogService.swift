//
//  LogService.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 18.12.2022.
//

struct LogService {
    
    // MARK: - Helper Types
    enum LogType: String, CaseIterable {
        case 🎧
        case 🎤
        case 🗣
        case 💰
        case 🌐
    }
    
    // MARK: - Private Properties
    private let enabledTypes: [LogType]
    
    // MARK: - Object Lifecycle
    init(enabledTypes: [LogType] = LogType.allCases) {
        self.enabledTypes = enabledTypes
    }
    
    // MARK: - Public Methods
    func write(_ logType: LogType, _ info: Any?...) {
        var infoArray = [Any]()
        for anyElement in info where anyElement != nil {
            infoArray.append(anyElement!)
        }
        let infoString = infoArray.map { String(describing: $0 ) }
        var logMessage = [logType.rawValue]
        logMessage.append(contentsOf: infoString)
        let message = logMessage.joined(separator: " ")
        log(message)
    }
    
    // MARK: - Private Methods
    private func isLoggingEnabled(_ text: String ) -> Bool {
        guard let firstType = text.first else { return false }
        return enabledTypes.map { $0.rawValue }.contains(String(firstType))
    }
    
    private func log(_ text: String) {
        guard isLoggingEnabled(text) else { return }
        print(text)
    }
}
