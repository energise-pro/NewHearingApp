//
//  SettingsView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol SettingsView: LocalizableView {
    
    func setPresenter(_ presenter: SettingsPresenterProtocol)
}
