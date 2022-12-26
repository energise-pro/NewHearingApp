//
//  WebPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import Foundation

protocol WebPresenterProtocol: AnyObject {

    func viewDidLoad()
    func didTapCloseButton()
}

final class WebPresenter: WebPresenterProtocol {
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: WebView
    private let url: URL
    private let title: String
    private let logService: LogService
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: WebView, url: URL, title: String, logService: LogService) {
        self.router = router
        self.view = view
        self.url = url
        self.title = title
        self.logService = logService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.setTitle(title)
        view.loadPage(for: url)
        let operation = "Load web page for \(title)"
        printDetails(operation: operation, url: url)
    }
    
    func didTapCloseButton() {
        router.performRoute(.dismiss(animated: true, completion: nil))
    }
    
    // MARK: - Private Methods
    private func printDetails(operation: String, url: URL) {
        let details = "| \(operation) | URL: \(url.absoluteString)"
        let line = String(repeating: "-", count: details.count)
        print("\n\(line)")
        logService.write(.🌐, details)
        print(line)
    }
}
