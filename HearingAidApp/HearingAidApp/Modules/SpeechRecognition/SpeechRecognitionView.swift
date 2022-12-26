//
//  SpeechRecognitionView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

protocol SpeechRecognitionView: LocalizableView {
    
    func setPresenter(_ presenter: SpeechRecognitionPresenterProtocol)
    func configureUIForWorkingState(_ isWorking: Bool)
    func setTextForTextView(_ text: String)
}
