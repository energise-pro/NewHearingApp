//
//  HearingAidView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol HearingAidView: LocalizableView {
    
    var isVolumeViewConfigured: Bool { get set }
    
    func setPresenter(_ presenter: HearingAidPresenterProtocol)
    func layoutIfNeeded()
    func configureSliderFillView(for value: Double)
    func configureVolumePercentageView(for value: Double)
    func configureScaleStackView(for value: Double)
    func setTitleForOutputDeviceLabel(_ title: String)
    func configureForWorknigState(_ isWorking: Bool)
}
