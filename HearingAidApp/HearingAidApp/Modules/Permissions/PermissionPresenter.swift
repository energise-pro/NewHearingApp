//
//  PermissionPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 18.12.2022.
//

import UIKit

protocol PermissionPresenterProtocol: AnyObject {
    
    var title: String { get }
    var subtitle: String { get }
    var image: UIImage? { get }
    
    func viewDidLoad()
    func didTapAllowButton()
    func didTapCloseButton()
}

final class PermissionPresenter: PermissionPresenterProtocol {
    
    // MARK: - Public Properties
    var title: String {
        return permissionType.title
    }
    
    var subtitle: String {
        return permissionType.subtitle
    }
    
    var image: UIImage? {
        return permissionType.image
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: PermissionsView
    private let permissionType: PermissionType
    private let audioService: AudioService
    private let speechRecognitionService: SpeechRecognitionService
    private let logService: LogService
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: PermissionsView, permissionType: PermissionType, audioService: AudioService, speechRecognitionService: SpeechRecognitionService, logService: LogService) {
        self.router = router
        self.view = view
        self.permissionType = permissionType
        self.audioService = audioService
        self.speechRecognitionService = speechRecognitionService
        self.logService = logService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUI()
        view.configureLocalization()
    }
    
    func didTapAllowButton() {
        switch permissionType {
        case .microphoneUsage:
            audioService.requestMicrophoneUsagePermission { [weak self] isSuccess in
                self?.printDetails(operation: "Microphone usage permission", isMicrophonePermission: true, isSuccess: isSuccess)
                guard isSuccess else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.router.performRoute(.dismiss(animated: true, completion: nil))
                }
            }
        case .speechRecognition:
            speechRecognitionService.requestSpeechRecognitionUsagePermission { [weak self] isSuccess in
                self?.printDetails(operation: "Speech recognition usage", isMicrophonePermission: false, isSuccess: isSuccess)
                guard isSuccess else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.router.performRoute(.dismiss(animated: true, completion: nil))
                }
            }
        }
    }
    
    func didTapCloseButton() {
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
    
    // MARK: - Private Methods
    private func printDetails(operation: String, isMicrophonePermission: Bool, isSuccess: Bool? = nil) {
        var details = "| \(operation) |"
        if let isSuccess = isSuccess {
            let statusDetails = " \(isSuccess ? "✅" : "❌") Status: \(isSuccess ? "Allowed" : "Deniend") |"
            details += statusDetails
        }
        let line = String(repeating: "-", count: details.count)
        print("\n\(line)")
        logService.write(isMicrophonePermission ? .🎤 : .🗣, details)
        print(line)
    }
}
