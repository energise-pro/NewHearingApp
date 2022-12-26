//
//  ServiceProvider.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import UIKit

protocol ServiceProdiver: AnyObject {
    
    var logService: LogService { get }
    var audioService: AudioService { get }
    var speechRecognitionService: SpeechRecognitionService { get }
    var purchasesService: PurchasesService { get }
    
    func didFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}
