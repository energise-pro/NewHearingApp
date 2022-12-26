//
//  HeadphonesConnectionView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol HeadphonesConnectionView: LocalizableView {
    
    func setPresenter(_ presenter: HeadphonesConnectionPresenterProtocol)
    func configureUI()
}
