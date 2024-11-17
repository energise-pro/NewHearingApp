import UIKit
import SwiftUI
import MediaPlayer
import AVKit

final class SHearinApViewController: PMUMainViewController {
    
    enum BottomButtonTabType: Int, CaseIterable {
        case noiseOff
        case stereo
        case templates
        case proSetup
        
        var image: UIImage {
            switch self {
            case .proSetup:
                return CAppConstants.Images.icProSetup
            case .noiseOff:
                return CAppConstants.Images.icNoiseOff
            case .stereo:
                return CAppConstants.Images.icStereo
            case .templates:
                return CAppConstants.Images.icTemplates
            }
        }
        
        var selectedImage: UIImage {
            switch self {
            case .proSetup:
                return CAppConstants.Images.icProSetup
            case .noiseOff:
                return CAppConstants.Images.icNoiseOffSelected
            case .stereo:
                return CAppConstants.Images.icStereoSelected
            case .templates:
                return CAppConstants.Images.icTemplates
            }
        }
        
        var title: String {
            switch self {
            case .proSetup:
                return "Setup".localized()
            case .noiseOff:
                return "No Noise".localized()
            case .stereo:
                return "Stereo".localized()
            case .templates:
                return "Templates".localized()
            }
        }
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var headphonesContainerView: UIView!
    @IBOutlet private weak var balanceFillView: UIView!
    @IBOutlet private weak var balanceBackgoundView: UIView!
    @IBOutlet private weak var balanceContainerView: UIView!
    @IBOutlet private weak var volumeContainer: UIView!
    @IBOutlet private weak var volumeScaleContainer: UIView!
    @IBOutlet private weak var volumePercentageContainer: UIView!
    @IBOutlet private weak var volumeFillContainer: UIView!
    @IBOutlet private weak var waveContainerView: UIView!
    
    @IBOutlet private weak var mainSwitchImageView: UIImageView!
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var headphonesImageView: UIImageView!
    
    @IBOutlet private weak var headphonesTitleLabel: UILabel!
    @IBOutlet private weak var powerInfoLabel: UILabel!
    @IBOutlet private weak var leftTitleLabel: UILabel!
    @IBOutlet private weak var rightTitleLabel: UILabel!
    @IBOutlet private weak var percentageTitleLabel: UILabel!
    
    @IBOutlet private weak var balanceSlider: UISlider!
    
    @IBOutlet private weak var volumeScaleStackView: UIStackView!
    
    @IBOutlet private weak var balanceFillViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var balanceFillViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var volumePercentageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var bottomImageViews: [UIImageView]!
    @IBOutlet private var bottomLabels: [UILabel]!
    @IBOutlet private weak var turnOnView: UIView!
    
    private var balanceCurrentValue: Double = 0.0
    private var volumePercentageValue: Double = 0.0
    private var isConfiguredVolumeView: Bool = false
    private var isConfiguredWaveView: Bool = false
    private let systemVolumeView = MPVolumeView()
    private var balanceTimer: Timer?
    private var volumeTimer: Timer?
    private var tooltip: TooltipView?
    private var maxVolumeValue: CGFloat = 130.0
    private var volumeUpdateWorkItem: DispatchWorkItem?
    
    private var cachedSystemVolumeSlider: UISlider? {
        return systemVolumeView.subviews.compactMap({ $0 as? UISlider }).first
    }
    
    private var cachedStackSubviews: [UIView] {
        return volumeScaleStackView.arrangedSubviews
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isConfiguredVolumeView else {
            return
        }
        isConfiguredVolumeView = true
        view.layoutIfNeeded()
        let volumeValue = SAudioKitServicesAp.shared.isUseSystemVolume ? SAudioKitServicesAp.shared.systemVolume : SAudioKitServicesAp.shared.microphoneVolume
        volumePercentageValue = volumeValue * maxVolumeValue
        updateVolumeView(on: volumePercentageValue)
        updateSliderFillView(on: SAudioKitServicesAp.shared.balanceValue)
        configureScaleStackView(with: volumePercentageValue)
//        configureWaveView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SAudioKitServicesAp.shared.setAudioEngine(SAudioKitServicesAp.shared.isStartedMixer)
        mainSwitchImageView.image = SAudioKitServicesAp.shared.isStartedMixer ? CAppConstants.Images.powerOn : CAppConstants.Images.powerOff
        hideTooltip()
        if !SAudioKitServicesAp.shared.isStartedMixer {
            showTooltip()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        SAudioKitServicesAp.shared.createRollingView()
//        configureWaveView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            let volumeValue = SAudioKitServicesAp.shared.isUseSystemVolume ? SAudioKitServicesAp.shared.systemVolume : SAudioKitServicesAp.shared.microphoneVolume
            self.volumePercentageValue = volumeValue * maxVolumeValue
            self.updateVolumeView(on: self.volumePercentageValue)
            self.updateSliderFillView(on: SAudioKitServicesAp.shared.balanceValue)
            self.configureScaleStackView(with: self.volumePercentageValue)
        } completion: { _ in
//            self.configureWaveView()
            SAudioKitServicesAp.shared.setAudioEngine(SAudioKitServicesAp.shared.isStartedMixer)
        }
    }
    
//    override func didChangeTheme() {
//        super.didChangeTheme()
//        SAudioKitServicesAp.shared.createRollingView()
//        configureWaveView()
//        updateMainColors()
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        print(BottomButtonTabType.allCases)
        BottomButtonTabType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.UnactiveButton_1)
            bottomLabels[index].textColor = UIColor.appColor(.White100) //UIColor.appColor(.UnactiveButton_1)
        }
        mainSwitchImageView.image = UIImage.init(systemName: "power")
        infoImageView.image = CAppConstants.Images.icInstructionInfo
        headphonesImageView.image = UIImage.init(named: "airplayIcon")
        
//        headphonesImageView.tintColor = UIColor.appColor(.UnactiveButton_1)
        balanceBackgoundView.backgroundColor = UIColor.appColor(.LightGrey20)
        volumeScaleContainer.backgroundColor = UIColor.appColor(.White100)
        volumeScaleContainer.layer.shadowOpacity = 0.2
        volumeScaleContainer.layer.shadowColor = UIColor.appColor(.Purple100)!.cgColor
        volumeScaleContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        volumeScaleContainer.layer.shadowRadius = 8.0
        
        headphonesTitleLabel.textColor = UIColor.appColor(.Purple100)
//        powerInfoLabel.textColor = UIColor.appColor(.UnactiveButton_2)
        
        headphonesTitleLabel.text = "No device".localized()
//        powerInfoLabel.text = "Tap The Power Button To Get Started".localized()
        leftTitleLabel.text = "Left".localized()
        rightTitleLabel.text = "Right".localized()
        
        balanceSlider.minimumTrackTintColor = .clear
        balanceSlider.maximumTrackTintColor = .clear
        balanceSlider.value = Float(SAudioKitServicesAp.shared.balanceValue)
        
        volumePercentageContainer.layer.shadowOpacity = 0.2
        volumePercentageContainer.layer.shadowColor = UIColor.appColor(.Purple100)!.cgColor
        volumePercentageContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        volumePercentageContainer.layer.shadowRadius = 8.0
        
        balanceContainerView.isHidden = MicroFineType.selectedMicrophone == .headphones
        
        SAudioKitServicesAp.shared.didChangeVolumeCompletion = { [weak self] volume in
            guard SAudioKitServicesAp.shared.isUseSystemVolume else {
                return
            }
            let percentage = volume * (self?.maxVolumeValue ?? 130)
            if !TInAppService.shared.isPremium && percentage >= 100 {
                self?.volumePercentageValue = 100
                DispatchQueue.main.async {
                    self?.updateVolumeView(on: 100)
                }
                let topViewController = AppsNavManager.shared.topViewController
                if let paywallController = topViewController, paywallController.isKind(of: PaywallViewController.self) {
                    return
                }
                AppsNavManager.shared.presentPaywallViewController(with: .openFromHearing)
            } else {
                self?.volumePercentageValue = percentage
                DispatchQueue.main.async {
                    self?.updateVolumeView(on: percentage)
                }
                
                SAudioKitServicesAp.shared.changeVolume(on: volume)
            }
        }
        
        SAudioKitServicesAp.shared.didInitialiseService = { [weak self] in
            guard let self = self else { return }
            if !self.isConfiguredWaveView, KAppConfigServic.shared.settings.appLaunchCount <= 1 {
                self.isConfiguredWaveView = true
//                self.configureWaveView()
            }
            self.mainSwitchImageView.image = SAudioKitServicesAp.shared.isStartedMixer ? CAppConstants.Images.powerOn : CAppConstants.Images.powerOff
        }
        
        updateMainColors()
        configureObserver()
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func setBottomButton(_ bottomButton: BottomButtonTabType, asSelected isSelected: Bool) {
        bottomImageViews[bottomButton.rawValue].tintColor = isSelected ? AThemeServicesAp.shared.activeColor : UIColor.appColor(.UnactiveButton_1)
        bottomImageViews[bottomButton.rawValue].image = isSelected ? bottomButton.selectedImage : bottomButton.image
        bottomLabels[bottomButton.rawValue].textColor = UIColor.appColor(.White100) //isSelected ? AThemeServicesAp.shared.activeColor : UIColor.appColor(.UnactiveButton_1)
    }
    
    private func updateMainColors() {
        setBottomButton(.noiseOff, asSelected: SAudioKitServicesAp.shared.isNoiseOffEnabled)
        setBottomButton(.stereo, asSelected: SAudioKitServicesAp.shared.isStereoEnabled)
//        mainSwitchImageView.image = SAudioKitServicesAp.shared.isStartedMixer ? CAppConstants.Images.powerOn : CAppConstants.Images.powerOff
        infoImageView.tintColor = AThemeServicesAp.shared.activeColor
        [leftTitleLabel, rightTitleLabel, percentageTitleLabel].forEach { $0?.textColor = AThemeServicesAp.shared.activeColor }
        [volumeFillContainer, balanceFillView].forEach { $0?.backgroundColor = AThemeServicesAp.shared.activeColor }
    }
    
    private func updateSliderFillView(on sliderValue: Double) {
        [balanceFillViewLeftConstraint, balanceFillViewRightConstraint].forEach { $0?.constant = 0 }
        if sliderValue > 0 {
            let widthMultiplier = (balanceBackgoundView.frame.width / 2) / CGFloat(abs(balanceSlider.maximumValue))
            balanceFillViewRightConstraint.constant = (CGFloat(CGFloat(sliderValue) * widthMultiplier))
        } else if sliderValue < 0 {
            let widthMultiplier = (balanceBackgoundView.frame.width / 2) / CGFloat(abs(balanceSlider.minimumValue))
            balanceFillViewLeftConstraint.constant = (CGFloat(CGFloat(sliderValue) * widthMultiplier))
        }
    }
    
    private func updateVolumeView(on volumeValue: Double) {
        percentageTitleLabel.text = "\(Int(volumeValue))%"
        let pathLenght = volumeContainer.bounds.height - volumePercentageContainer.bounds.height
        let constraintValue = (pathLenght * volumeValue) / maxVolumeValue
        let volumePercentageOffsetY = volumeContainer.bounds.height - volumePercentageContainer.bounds.height - constraintValue
        volumePercentageViewBottomConstraint.constant = constraintValue
        for view in cachedStackSubviews {
            let isUnderPrecentageView = (view.frame.origin.y + volumeScaleStackView.frame.origin.y) > volumePercentageOffsetY
            let newColor = isUnderPrecentageView ? UIColor.white : UIColor.appColor(.Purple100)
            if view.backgroundColor != newColor {
                view.backgroundColor = newColor
            }
        }
        volumeUpdateWorkItem?.cancel()
        let newWorkItem = DispatchWorkItem { [weak self] in
            self?.updateSystemVolume(to: volumeValue)
        }
        volumeUpdateWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: newWorkItem)
    }

    private func updateSystemVolume(to volumeValue: Double) {
        guard SAudioKitServicesAp.shared.isUseSystemVolume,
              let slider = cachedSystemVolumeSlider else { return }
        slider.value = Float(volumeValue / maxVolumeValue)
    }
    
    private func configureScaleStackView(with volumeValue: Double) {
        for arrangeSubview in volumeScaleStackView.arrangedSubviews {
            arrangeSubview.removeFromSuperview()
        }
        
        let heightBetweenView = UIDevice.current.userInterfaceIdiom == .pad ? 14.5 : 6.5
        let countOfViews = Int(volumeScaleStackView.bounds.height / heightBetweenView)
        let pathLenght = volumeContainer.bounds.height - volumePercentageContainer.bounds.height
        let constraintValue = (pathLenght * volumeValue) / maxVolumeValue
        let volumePercentageOffsetY = volumeContainer.bounds.height - volumePercentageContainer.bounds.height - constraintValue
        var scaleOffsetY: Double = volumeScaleStackView.frame.origin.y
        (0..<countOfViews).forEach { index in
            scaleOffsetY += heightBetweenView
            let viewWidth = index == 0 || index == countOfViews - 1 || (index % 5 == 0) ? volumeScaleStackView.bounds.width : volumeScaleStackView.bounds.width * 0.7
            let view = UIView()
            view.backgroundColor = scaleOffsetY > volumePercentageOffsetY ? UIColor.white : UIColor.appColor(.Purple100)
            [view.heightAnchor.constraint(equalToConstant: 1.5), view.widthAnchor.constraint(equalToConstant: viewWidth)].forEach {
                $0.isActive = true
            }
            volumeScaleStackView.addArrangedSubview(view)
        }
    }
    
    private func configureWaveView() {
        waveContainerView.subviews.forEach { $0.removeFromSuperview() }
        let waveView = SAudioKitServicesAp.shared.microphoneRollingView
        let childView = UIHostingController(rootView: waveView)
        childView.view.frame = waveContainerView.bounds
        waveContainerView.addSubview(childView.view)
    }
    
    private func showTooltip() {
        tooltip = TooltipView(text: "Tap to get started".localized())
        guard let tooltip = tooltip else { return }
        
        tooltip.alpha = 0
        var tooltipRect = tooltip.frame
        tooltipRect.origin.x = (view.frame.width - tooltipRect.width) / 2.0
        tooltipRect.origin.y = CGRectGetMinY(turnOnView.frame) - tooltipRect.height - 10.0
        tooltip.frame = tooltipRect
        view.addSubview(tooltip)
        
        UIView.animate(withDuration: 0.3) {
            tooltip.alpha = 1
        }
        
        tooltip.transform = CGAffineTransform(translationX: 0, y: -10)
        
        startInfiniteBounceAnimation()
    }
    
    private func hideTooltip() {
        self.tooltip?.removeFromSuperview()
        self.tooltip?.layer.removeAllAnimations()
        self.tooltip = nil
    }
    
    private func startInfiniteBounceAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
            self.tooltip?.transform = CGAffineTransform(translationX: 0, y: 10) // Move down by 10 points
        })
    }
    
    private func updateHeadphonesTitleLabel() {
        headphonesTitleLabel.text = SAudioKitServicesAp.shared.connectedHeadphones ? SAudioKitServicesAp.shared.outputDeviceName : "No device".localized()
    }
    
    @objc private func audioRouteChanged(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            self?.updateHeadphonesTitleLabel()
        }
    }
    
    // MARK: - IBActions
    @IBAction private func mainButtonAction(_ sendner: UIButton) {
        guard SAudioKitServicesAp.shared.isStartedMixer || TInAppService.shared.isPremium || SAudioKitServicesAp.shared.countOfUsingAid < 2 else {
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentPaywallViewController(with: .openFromHearing)
            return
        }

        guard SAudioKitServicesAp.shared.recordPermission != .denied else {
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentHMicrophPermisApViewController()
            return
        }

        if !SAudioKitServicesAp.shared.isStartedMixer && !SAudioKitServicesAp.shared.connectedHeadphones {
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentDHeadphsRemindApViewController()
            return
        }
        
        let newState = !SAudioKitServicesAp.shared.isStartedMixer
        SAudioKitServicesAp.shared.setAudioEngine(newState)
        newState ? TapticEngine.customHaptic.playOn() : TapticEngine.customHaptic.playOff()
        mainSwitchImageView.image = newState ? CAppConstants.Images.powerOn : CAppConstants.Images.powerOff
        newState ? hideTooltip() : showTooltip()
        newState && SAudioKitServicesAp.shared.countOfUsingAid % 3 == 0 ? KAppConfigServic.shared.settings.presentAppRatingAlert() : Void()
        newState ? SAudioKitServicesAp.shared.increaseCountOfUsing(for: .aid) : Void()
        
        let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
        KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.microphone.rawValue)_\(stringState)"])
    }
    
    @IBAction private func bottomButtonsAction(_ sender: UIButton) {
        guard let buttonType = BottomButtonTabType(rawValue: sender.tag) else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        switch buttonType {
        case .proSetup:
            AppsNavManager.shared.presentErdSetupViewController(with: self)
            KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.proSetup.rawValue])
        case .noiseOff:
            let newState = !SAudioKitServicesAp.shared.isNoiseOffEnabled
            SAudioKitServicesAp.shared.setNoiseOFF(newState)
            setBottomButton(.noiseOff, asSelected: newState)
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.noise.rawValue)_\(stringState)"])
        case .stereo:
            let newState = !SAudioKitServicesAp.shared.isStereoEnabled
            SAudioKitServicesAp.shared.setStereo(newState)
            setBottomButton(.stereo, asSelected: newState)
            
            let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
            KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.stereo.rawValue)_\(stringState)"])
        case .templates:
            AppsNavManager.shared.presentQTemplateApViewController(with: self)
            KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.templates.rawValue])
        }
    }
    
    @IBAction private func infoButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentCustomVideoFInstructApViewController()
        KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.info.rawValue])
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        let senderValue = Double(sender.value).rounded(toPlaces: 2)
        guard balanceCurrentValue != senderValue else {
            return
        }
        TapticEngine.selection.feedback()
        balanceCurrentValue = senderValue
        updateSliderFillView(on: senderValue)
        SAudioKitServicesAp.shared.changeBalance(on: senderValue)
        
        balanceTimer?.invalidate()
        balanceTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeBalance.rawValue])
        }
    }
    
    @IBAction private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        func trackAnalytic() {
            volumeTimer?.invalidate()
            volumeTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
                KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeVolume.rawValue])
            }
        }
        
        let location = sender.location(in: volumeContainer)
        let percentage = maxVolumeValue - (location.y / volumeContainer.bounds.height) * maxVolumeValue
        if !TInAppService.shared.isPremium && percentage >= 100 {
            let topViewController = AppsNavManager.shared.topViewController
            if let paywallController = topViewController, paywallController.isKind(of: PaywallViewController.self) {
                return
            }
            AppsNavManager.shared.presentPaywallViewController(with: .openFromHearing)
            TapticEngine.selection.feedback()
            volumePercentageValue = 100
            updateVolumeView(on: 100)
            SAudioKitServicesAp.shared.changeVolume(on: 100 / maxVolumeValue)
            trackAnalytic()
            return
        }
        if percentage > 0 && percentage < maxVolumeValue, volumePercentageValue != percentage {
            TapticEngine.selection.feedback()
            volumePercentageValue = percentage
            updateVolumeView(on: percentage)
            SAudioKitServicesAp.shared.changeVolume(on: percentage / maxVolumeValue)
            trackAnalytic()
        } else if volumePercentageValue != 0 && volumePercentageValue != maxVolumeValue && volumePercentageValue != percentage {
            let newPercentage: Double = percentage > 50 ? maxVolumeValue : 0
            TapticEngine.selection.feedback()
            volumePercentageValue = newPercentage
            updateVolumeView(on: newPercentage)
            SAudioKitServicesAp.shared.changeVolume(on: newPercentage / maxVolumeValue)
            trackAnalytic()
        }
    }
}

// MARK: - ErdSetupViewControllerDelegate
extension SHearinApViewController: ErdSetupViewControllerDelegate {
    
    func didUpdateSystemVolumeValue() {
        volumePercentageValue = SAudioKitServicesAp.shared.microphoneVolume * maxVolumeValue
        updateVolumeView(on: volumePercentageValue)
    }
    
    func didChangeMicrophone() {
        balanceContainerView.isHidden = MicroFineType.selectedMicrophone == .headphones
    }
}

// MARK: - ErdSetupViewControllerDelegate
extension SHearinApViewController: QTemplateApViewControllerDelegate {
    
    func didChangeTemplatesValue() {
        setBottomButton(.templates, asSelected: SAudioKitServicesAp.shared.isTemplatesEnabled)
    }
}
