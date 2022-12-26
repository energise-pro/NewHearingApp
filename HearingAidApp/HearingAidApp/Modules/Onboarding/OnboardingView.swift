//
//  OnboardingView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol OnboardingView: LocalizableView {
    
    func setPresenter(_ presenter: OnboardingPresenterProtocol)
    func configureUI()
    func scrollToItem(at index: Int)
    func showCloseButton()
    func setContinueButtonEnabled(_ isEnabled: Bool)
}
