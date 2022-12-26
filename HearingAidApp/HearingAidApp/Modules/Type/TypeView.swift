//
//  TypeView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 23.12.2022.
//

protocol TypeView: LocalizableView {
    
    func setPresenter(_ presenter: TypePresenterProtocol)
    func configureUI()
    func setInputHidden(_ isHidden: Bool)
    func setResultText(_ text: String)
    func clearTextField()
}
