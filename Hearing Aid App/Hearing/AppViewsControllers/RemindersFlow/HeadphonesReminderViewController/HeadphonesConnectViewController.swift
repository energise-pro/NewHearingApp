import UIKit
import AVKit

final class HeadphonesConnectViewController: UIViewController {
    private lazy var closeBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
            return btn
    }()
    
    private lazy var topBgImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var btmView: UIView = {
        let vie = UIView()
        vie.clipsToBounds = true
        vie.layer.cornerRadius = 15
        vie.translatesAutoresizingMaskIntoConstraints = false
        return vie
    }()
    private lazy var btmBgImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    private lazy var topLabels: UILabel = {
        let labl = UILabel()
        labl.translatesAutoresizingMaskIntoConstraints = false
        return labl
    }()
    
    private lazy var btmLabels: UILabel = {
        let labl = UILabel()
        labl.translatesAutoresizingMaskIntoConstraints = false
        return labl
    }()
    
    private lazy var btnSelectDevice: UIButton = {
            let btn = UIButton(type: .custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle("Select Device", for: .normal)
            btn.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 28
            btn.setImage(UIImage(named: "airplayIcon"), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 15)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)

            btn.tintColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
            btn.setTitleColor(UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            btn.addTarget(self, action: #selector(selectDeviceTapped), for: .touchUpInside)
            return btn
    }()
    
    private lazy var btnOk: UIButton = {
            let btn = UIButton(type: .custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            btn.layer.cornerRadius = 28
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            btn.setTitle("Okay, Got It", for: .normal)
            btn.addTarget(self, action: #selector(okBtnTapped), for: .touchUpInside)
            return btn
    }()
    
    private lazy var routePickerView: AVRoutePickerView = {
        let routePickerView = AVRoutePickerView(frame: .zero)
        routePickerView.isHidden = true
        btnSelectDevice.addSubview(routePickerView)
        return routePickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func uiLoad() {
        closeBtn.setImage(UIImage(named: "closeBtns"), for: .normal)
        topBgImage.image = UIImage(named: "headphoneTopImg")
        topLabels.text = "Connect Headphones"
        topLabels.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        topLabels.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        topLabels.textAlignment = .center
        btmLabels.text = "Please connect your headphones \nto continue with the best hearing aid."
        btmLabels.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        btmLabels.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        btmLabels.textAlignment = .center
        btmLabels.numberOfLines = 2
        btmBgImage.image = UIImage(named: "bgHeadphone")
        
        insertElement()
    }
    
    private func insertElement() {
        view.addSubview(topBgImage)
        view.addSubview(closeBtn)
        view.addSubview(btmView)
        btmView.addSubview(btmBgImage)
        btmView.addSubview(topLabels)
        btmView.addSubview(btmLabels)
        btmView.addSubview(btnSelectDevice)
        btmView.addSubview(btnOk)
    }
    
    private func layoutElement() {
        NSLayoutConstraint.activate([
            topBgImage.topAnchor.constraint(equalTo: view.topAnchor),
            topBgImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBgImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBgImage.bottomAnchor.constraint(equalTo: btmView.topAnchor, constant: 20),
            closeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            closeBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            closeBtn.widthAnchor.constraint(equalToConstant: 68),
            closeBtn.heightAnchor.constraint(equalToConstant: 68),
            
            btmView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            btmView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            btmView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            btmView.heightAnchor.constraint(equalToConstant: 340 + view.safeAreaInsets.bottom),
            btmBgImage.leadingAnchor.constraint(equalTo: btmView.leadingAnchor),
            btmBgImage.topAnchor.constraint(equalTo: btmView.topAnchor),
            btmBgImage.trailingAnchor.constraint(equalTo: btmView.trailingAnchor),
            btmBgImage.bottomAnchor.constraint(equalTo: btmView.bottomAnchor),
            
            btnOk.leadingAnchor.constraint(equalTo: btmView.leadingAnchor, constant: 16),
            btnOk.trailingAnchor.constraint(equalTo: btmView.trailingAnchor, constant: -16),
            btnOk.bottomAnchor.constraint(equalTo: btmView.bottomAnchor, constant: -85),
            btnOk.heightAnchor.constraint(equalToConstant: 56),
            btnSelectDevice.leadingAnchor.constraint(equalTo: btmView.leadingAnchor, constant: 16),
            btnSelectDevice.trailingAnchor.constraint(equalTo: btmView.trailingAnchor, constant: -16),
            btnSelectDevice.bottomAnchor.constraint(equalTo: btnOk.topAnchor, constant: -20),
            btnSelectDevice.heightAnchor.constraint(equalToConstant: 56),
            btmLabels.leadingAnchor.constraint(equalTo: btmView.leadingAnchor, constant: 16),
            btmLabels.trailingAnchor.constraint(equalTo: btmView.trailingAnchor, constant: -16),
            btmLabels.bottomAnchor.constraint(equalTo: btnSelectDevice.topAnchor, constant: -28),
            btmLabels.heightAnchor.constraint(equalToConstant: 50),
            topLabels.leadingAnchor.constraint(equalTo: btmView.leadingAnchor, constant: 16),
            topLabels.trailingAnchor.constraint(equalTo: btmView.trailingAnchor, constant: -16),
            topLabels.bottomAnchor.constraint(equalTo: btmLabels.topAnchor, constant: -12),
            topLabels.topAnchor.constraint(equalTo: btmView.topAnchor, constant: 28),
            topLabels.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    override func viewSafeAreaInsetsDidChange() {
        layoutElement()
    }
    
    // MARK: - Actions
       @objc private func closeBtnTapped() {
           print("Close button tapped")
           self.dismiss(animated: true, completion: nil)
       }

       @objc private func selectDeviceTapped() {
           print("Select Device button tapped")
           KAppConfigServic.shared.analytics.track(.v2HeadphonesReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.airPlay.rawValue])
           TapticEngine.impact.feedback(.medium)
           routePickerView.present()
       }

       @objc private func okBtnTapped() {
           print("OK button tapped")
           KAppConfigServic.shared.analytics.track(.v2HeadphonesReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
           TapticEngine.impact.feedback(.medium)
           dismiss(animated: true)
       }
    //MARK: - Notification actions
    @objc private func audioRouteChanged(notification: NSNotification) {
        guard let audioRouteChangeReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else {
            return
        }

        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            KAppConfigServic.shared.analytics.track(.v2HeadphonesReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.connected.rawValue])
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if SAudioKitServicesAp.shared.connectedHeadphones {
                    SAudioKitServicesAp.shared.setAudioEngine(true)
                }
                self?.dismiss(animated: true)
            }
        default:
            break
        }
    }
}
