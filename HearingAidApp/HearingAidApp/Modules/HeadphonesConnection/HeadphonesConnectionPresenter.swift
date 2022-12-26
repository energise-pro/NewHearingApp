//
//  HeadphonesConnectionPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 18.12.2022.
//

protocol HeadphonesConnectionPresenterProtocol: AnyObject {
    
    func viewDidLoad()
    func didTapGetStartedButton()
}

final class HeadphonesConnectionPresenter: HeadphonesConnectionPresenterProtocol {
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: HeadphonesConnectionView
    private let audioService: AudioService
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: HeadphonesConnectionView, audioService: AudioService) {
        self.router = router
        self.view = view
        self.audioService = audioService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUI()
        view.configureLocalization()
    }
    
    func didTapGetStartedButton() {
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
}
