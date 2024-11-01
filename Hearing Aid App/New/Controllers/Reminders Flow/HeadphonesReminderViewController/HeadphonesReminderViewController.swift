import UIKit
import AVKit

private struct Defaults {
    
    struct Sizes {
        static let minimumTitleTopInset: CGFloat = 40.0
        static let maximumTitleTopInset: CGFloat = 80.0
        
        static let minimumTitleFontSize: CGFloat = 22.0
        static let maximumTitleFontSize: CGFloat = 28.0
        
        static let minimumDescriptionFontSize: CGFloat = 16.0
        static let maximumDescriptionFontSize: CGFloat = 25.0
    }
}

final class HeadphonesReminderViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var airplayIconImageView: UIImageView!
    
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var airplayContainerView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var buttonTitleLabel: UILabel!
    @IBOutlet private weak var airplayTitleLabel: UILabel!
    
    @IBOutlet private weak var topLabelConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    private let player = AVPlayer()
    private let playerLayer = AVPlayerLayer()
    
    private lazy var routePickerView: AVRoutePickerView = {
        let routePickerView = AVRoutePickerView(frame: .zero)
        routePickerView.isHidden = true
        airplayContainerView.addSubview(routePickerView)
        return routePickerView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfiguration.shared.analytics.track(.v2HeadphonesReminder, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
        configureUI()
        configureObserver()
        chargePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = thumbnailImageView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        AppConfiguration.shared.analytics.track(.v2HeadphonesReminder, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
    }
    
    @IBAction private func airplayButtonAction(_ sender: UIButton) {
        AppConfiguration.shared.analytics.track(.v2HeadphonesReminder, with: [AnalyticsAction.action.rawValue: AnalyticsAction.airPlay.rawValue])
        TapticEngine.impact.feedback(.medium)
        routePickerView.present()
    }

    //MARK: - Private methods
    private func configureUI() {
        buttonContainerView.backgroundColor = ThemeService.shared.activeColor
        buttonTitleLabel.textColor = .white
        airplayIconImageView.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.8)
        [descriptionLabel, airplayTitleLabel].forEach { $0?.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.8) }
        titleLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        
        titleLabel.text = "Hello".localized()
        descriptionLabel.text = "Please connect your headphones for correctly hearing aid work".localized()
        airplayTitleLabel.text = "Select playback device".localized()
        buttonTitleLabel.text = "Get started".localized()
        
        let fontMultiplier: CGFloat = 0.03
        let topMultiplier: CGFloat = 0.08
        let titleFontSize = min(max(.appHeight * fontMultiplier, Defaults.Sizes.minimumTitleFontSize), Defaults.Sizes.maximumTitleFontSize)
        let descriptionFontSize = min(max(.appHeight * fontMultiplier, Defaults.Sizes.minimumDescriptionFontSize), Defaults.Sizes.maximumDescriptionFontSize)
        
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionFontSize, weight: .medium)
        topLabelConstraint.constant = min(max(.appHeight * topMultiplier, Defaults.Sizes.minimumTitleTopInset), Defaults.Sizes.maximumTitleTopInset)
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFinishedPlayingNotificationTriggered), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotificationTriggered), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotificationNotificationTriggered), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func chargePlayer() {
        let videoURL: URL = Bundle.main.url(forResource: "headphones", withExtension: "mp4")!
        player.replaceCurrentItem(with: AVPlayerItem.init(url: videoURL))
        
        playerLayer.frame = thumbnailImageView.bounds
        thumbnailImageView.layer.addSublayer(playerLayer)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        player.actionAtItemEnd = .none
    }
    
    private func play() {
        player.seek(to: CMTime.zero)
        resume()
    }
    
    private func resume() {
        player.play()
    }
    
    private func pause() {
        player.pause()
    }
    
    //MARK: - Notification actions
    @objc private func audioRouteChanged(notification: NSNotification) {
        guard let audioRouteChangeReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else {
            return
        }

        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            AppConfiguration.shared.analytics.track(.v2HeadphonesReminder, with: [AnalyticsAction.action.rawValue: AnalyticsAction.connected.rawValue])
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if AudioKitService.shared.connectedHeadphones {
                    AudioKitService.shared.setAudioEngine(true)
                }
                self?.dismiss(animated: true)
            }
        default:
            break
        }
    }
    
    @objc func playerItemFinishedPlayingNotificationTriggered(notification: Notification) {
        play()
    }
    
    @objc func didBecomeActiveNotificationTriggered(notification: Notification) {
        resume()
    }
    
    @objc func willResignActiveNotificationNotificationTriggered(notification: Notification) {
        pause()
    }
}
