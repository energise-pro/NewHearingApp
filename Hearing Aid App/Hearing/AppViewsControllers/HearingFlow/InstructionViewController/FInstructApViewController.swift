import UIKit
import AVFoundation

final class FInstructApViewController: PMUMainViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    
    private let player = AVPlayer()
    private let playerLayer = AVPlayerLayer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SAudioKitServicesAp.shared.setMusicMode(SAudioKitServicesAp.shared.isMusicModeEnabled)
    }
    
    // MARK: - Private methods
    private func chargePlayer() {
       // player.replaceCurrentItem(with: AVPlayerItem.init(url:))
        
        playerLayer.frame = thumbnailImageView.bounds
        thumbnailImageView.layer.addSublayer(playerLayer)
        playerLayer.player = player
        if UIDevice.current.userInterfaceIdiom == .phone {
            playerLayer.videoGravity = .resizeAspectFill
        }
        player.actionAtItemEnd = .none
        
        if !SAudioKitServicesAp.shared.connectedHeadphones {
            SAudioKitServicesAp.shared.overrideOutputAudioPort(on: .speaker)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFinishedPlayingNotificationTriggered), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotificationTriggered), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotificationNotificationTriggered), name: UIApplication.willResignActiveNotification, object: nil)
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
    
    @objc private func playerItemFinishedPlayingNotificationTriggered(notification: Notification) {
        play()
    }
    
    @objc private func didBecomeActiveNotificationTriggered(notification: Notification) {
        resume()
    }
    
    @objc private func willResignActiveNotificationNotificationTriggered(notification: Notification) {
        pause()
    }

    // MARK: - IBActions
    @IBAction private func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        TapticEngine.impact.feedback(.medium)
        switch sender.state {
        case .began, .changed:
            pause()
        default:
            resume()
        }
    }
    
    @IBAction private func closeAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
    }
}
