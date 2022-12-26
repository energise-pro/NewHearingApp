//
//  LanguagesListPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

import Foundation

protocol LanguagesListPresenterProtocol: AnyObject {
    
    var title: String { get }
    var numberOfRows: Int { get }
    var dismissAction: ((Locale) -> Void)? { get set }
    
    func viewDidLoad()
    func didTapCloseButton()
    func configure(cell: LanguageTableViewCell, forRowAt index: Int)
    func didSelectRow(at index: Int)
}

final class LanguagesListPresenter: LanguagesListPresenterProtocol {
    
    // MARK: - Public Properties
    var title: String {
        return "Available Languages".localized
    }
    
    var numberOfRows: Int {
        return locales.count
    }
    
    var dismissAction: ((Locale) -> Void)?
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: LanguagesListView
    private let locales: [Locale]
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: LanguagesListView, locales: [Locale]) {
        self.router = router
        self.view = view
        self.locales = locales
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUI()
        view.configureLocalization()
    }
    
    func didTapCloseButton() {
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
    
    func configure(cell: LanguageTableViewCell, forRowAt index: Int) {
        cell.configure(for: locales[index])
    }
    
    func didSelectRow(at index: Int) {
        dismissAction?(locales[index])
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
}
