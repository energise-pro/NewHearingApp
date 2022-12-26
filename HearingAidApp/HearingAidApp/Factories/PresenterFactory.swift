//
//  PresenterFactory.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import Foundation

protocol PresenterFactoryProtocol {
    
    func makeOnboardingPresenter(for view: OnboardingView) -> OnboardingPresenterProtocol
    func makeWebPresenter(for view: WebView, url: URL, title: String) -> WebPresenterProtocol
    func makePermissionPresenter(for view: PermissionsView, with permissionType: PermissionType) -> PermissionPresenterProtocol
    func makeHeadphonesConnectionPresenter(for view: HeadphonesConnectionView) -> HeadphonesConnectionPresenterProtocol
    func makePaywallPresenter(for view: PaywallView) -> PaywallPresenterProtocol
    func makeHearingAidPresenter(for view: HearingAidView) -> HearingAidPresenterProtocol
    func makeSpeechRecognitionPresenter(for view: SpeechRecognitionView) -> SpeechRecognitionPresenterProtocol
    func makeLanguagesListPresenter(for view: LanguagesListView, locales: [Locale]) -> LanguagesListPresenterProtocol
    func makeSettingsPresenter(for view: SettingsView) -> SettingsPresenterProtocol
    func makeTypePresenter(for view: TypeView) -> TypePresenterProtocol
}

final class PresenterFactory: PresenterFactoryProtocol {
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let serviceProvider: ServiceProdiver
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, serviceProvider: ServiceProdiver) {
        self.router = router
        self.serviceProvider = serviceProvider
    }
    
    // MARK: - Public Methods
    func makeOnboardingPresenter(for view: OnboardingView) -> OnboardingPresenterProtocol {
        return OnboardingPresenter(router: router,
                                   view: view,
                                   purchasesService: serviceProvider.purchasesService)
    }
    
    func makeWebPresenter(for view: WebView, url: URL, title: String) -> WebPresenterProtocol {
        return WebPresenter(router: router,
                            view: view,
                            url: url,
                            title: title,
                            logService: serviceProvider.logService)
    }
    
    func makePermissionPresenter(for view: PermissionsView, with permissionType: PermissionType) -> PermissionPresenterProtocol {
        return PermissionPresenter(router: router,
                                   view: view,
                                   permissionType: permissionType,
                                   audioService: serviceProvider.audioService,
                                   speechRecognitionService: serviceProvider.speechRecognitionService,
                                   logService: serviceProvider.logService)
    }
    
    func makeHeadphonesConnectionPresenter(for view: HeadphonesConnectionView) -> HeadphonesConnectionPresenterProtocol {
        return HeadphonesConnectionPresenter(router: router,
                                             view: view,
                                             audioService: serviceProvider.audioService)
    }
    
    func makePaywallPresenter(for view: PaywallView) -> PaywallPresenterProtocol {
        return PaywallPresenter(router: router,
                                view: view,
                                purchasesService: serviceProvider.purchasesService)
    }
    
    func makeHearingAidPresenter(for view: HearingAidView) -> HearingAidPresenterProtocol {
        return HearingAidPresenter(router: router,
                                   view: view,
                                   audioService: serviceProvider.audioService,
                                   purchasesService: serviceProvider.purchasesService)
    }
    
    func makeSpeechRecognitionPresenter(for view: SpeechRecognitionView) -> SpeechRecognitionPresenterProtocol {
        return SpeechRecognitionPresenter(router: router,
                                          view: view,
                                          audioService: serviceProvider.audioService,
                                          speechRecognitionService: serviceProvider.speechRecognitionService,
                                          purchasesService: serviceProvider.purchasesService)
    }
    
    func makeLanguagesListPresenter(for view: LanguagesListView, locales: [Locale]) -> LanguagesListPresenterProtocol {
        return LanguagesListPresenter(router: router,
                                      view: view,
                                      locales: serviceProvider.speechRecognitionService.supportedLocales())
    }
    
    func makeSettingsPresenter(for view: SettingsView) -> SettingsPresenterProtocol {
        return SettingsPresenter(router: router,
                                 view: view,
                                 purchasesService: serviceProvider.purchasesService)
    }
    
    func makeTypePresenter(for view: TypeView) -> TypePresenterProtocol {
        return TypePresenter(router: router,
                                 view: view)
    }
}
