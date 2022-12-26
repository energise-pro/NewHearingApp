//
//  TypePresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 23.12.2022.
//

protocol TypePresenterProtocol: AnyObject {
    
    var emptyStateText: String { get }
    
    func viewDidLoad()
    func didTapPrimaryButton()
    func didTapClearButton()
    func didTapFullScreenButton()
    func didTypeText(_ text: String?)
}

final class TypePresenter: TypePresenterProtocol {
    
    // MARK: - Public Properties
    var emptyStateText: String {
        return "Tap to Type".localized
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: TypeView
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: TypeView) {
        self.router = router
        self.view = view
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUI()
        view.configureLocalization()
    }
    
    func didTapPrimaryButton() {
        view.setInputHidden(false)
    }
    
    func didTapClearButton() {
        view.clearTextField()
    }
    
    func didTapFullScreenButton() {
        view.setInputHidden(true)
    }
    
    func didTypeText(_ text: String?) {
        view.setResultText(text ?? "")
    }
}
