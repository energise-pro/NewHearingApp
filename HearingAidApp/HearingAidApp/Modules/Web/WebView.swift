//
//  WebView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import Foundation

protocol WebView: PresentableView {

    func setPresenter(_ presenter: WebPresenterProtocol)
    func setTitle(_ title: String)
    func loadPage(for url: URL)
}
