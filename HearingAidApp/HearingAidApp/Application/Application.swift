//
//  Application.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import UIKit

final class Application: ServiceProdiver {

    // MARK: - Public Properties
    private(set) lazy var logService = LogService()
    private(set) lazy var audioService = AudioService(logService: logService)
    private(set) lazy var speechRecognitionService = SpeechRecognitionService()
    private(set) lazy var purchasesService = PurchasesService(apiKey: purchasesServiceApiKey, logService: logService)
    
    // MARK: - Private Properties
    private let purchasesServiceApiKey = "app_9zuUysuyLvf6Z1TcXfWVZzK98jF1cW"
    
    // MARK: - Public Methods
    func didFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        purchasesService.start()
    }
}
