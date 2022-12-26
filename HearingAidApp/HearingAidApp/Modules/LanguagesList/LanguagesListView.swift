//
//  LanguagesListView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

protocol LanguagesListView: LocalizableView {
    
    func configureUI()
    func setPresenter(_ presenter: LanguagesListPresenterProtocol)
}
