//
//  PaywallView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol PaywallView: LocalizableView {
    
    func setPresenter(_ presenter: PaywallPresenterProtocol)
    func setSelectedProductView(at index: Int)
    func setProductTrialLabelsHidden(_ isHidden: Bool)
    func setSwitchControlEnabled(_ isEnabled: Bool)
    func setProductCardsHidden(_ isHidden: Bool)
}
