//
//  WebViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    // MARK: - Private Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var webView: WKWebView!
    private var presenter: WebPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapCloseButton() {
        presenter.didTapCloseButton()
    }
}

// MARK: - WebView
extension WebViewController: WebView {
    
    func setPresenter(_ presenter: WebPresenterProtocol) {
        self.presenter = presenter
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func loadPage(for url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
