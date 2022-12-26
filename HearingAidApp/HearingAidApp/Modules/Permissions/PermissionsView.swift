//
//  PermissionsView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol PermissionsView: LocalizableView {
    
    func setPresenter(_ presenter: PermissionPresenterProtocol)
    func configureUI()
}
