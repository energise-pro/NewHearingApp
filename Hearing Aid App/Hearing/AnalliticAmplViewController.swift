import UIKit

final class HAnalliticAViewController: UIViewController, KGradientablView {

    @IBInspectable var isHorizontal: Bool = false {
        didSet {
            if isViewLoaded {
                view.transform = isHorizontal ? CGAffineTransform.init(rotationAngle: .pi/2) : .identity
            }
        }
    }

    //back Amplitude view
    private let nVbackgrounAmplitView = SpringView()
    private let gBbackgrounAmplitudeMask = GSprinImageView(image: #imageLiteral(resourceName: "volume"))
    let gradient: CAGradientLayer = CAGradientLayer()

    //front Amplitude view
    private let frontAmplitudeView = SpringView()
    private let frontAmplitudeMask = UIImageView(image: #imageLiteral(resourceName: "volume"))

//    let hearingAid = HearingAid.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupAmplitudeView()
        setupUIColor()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupUIColor),
                                               name: ThemeDidChangeNotificationName,
                                               object: nil)
    }

    private func setupAmplitudeView() {
        addGradientOn(view: nVbackgrounAmplitView, at: 0, colors: Theme.current.gradientColors)

        nVbackgrounAmplitView.backgroundColor = .clear
        gBbackgrounAmplitudeMask.contentMode = .scaleToFill
        nVbackgrounAmplitView.mask = gBbackgrounAmplitudeMask
        view.addSubview(nVbackgrounAmplitView)

        frontAmplitudeMask.contentMode = .scaleToFill

        frontAmplitudeView.mask = frontAmplitudeMask

        view.addSubview(frontAmplitudeView)

        frontAmplitudeView.alpha = 0
        nVbackgrounAmplitView.alpha = 0
        
        AudioKitService.shared.didChangeAmplitudeCompletion = { [weak self] value in
            self?.updateAmplitude(on: value)
        }
        animateAppearance()
    }

    func animateAppearance() {
        frontAmplitudeView.alpha = 0
        nVbackgrounAmplitView.alpha = 0
        frontAmplitudeView.animate(name:"pop")
        nVbackgrounAmplitView.animate(name:"pop")
    }

    private func updateAmplitude(on value: Float) {
        let height = view.bounds.height
        let y = height - (height * CGFloat(value))
        frontAmplitudeView.frame.size.height = y
        frontAmplitudeView.frame.origin.y = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayerFrame()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func setupUIColor() {
        updateGradientColors(colors: Theme.current.gradientColors)
        nVbackgrounAmplitView.tintColor = Theme.buttonActiveColor
        frontAmplitudeView.backgroundColor = Theme.buttonInactiveColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFrame()
    }

    func updateFrame() {
        nVbackgrounAmplitView.frame = view.bounds
        gBbackgrounAmplitudeMask.frame = nVbackgrounAmplitView.bounds
        frontAmplitudeView.frame = nVbackgrounAmplitView.frame
        frontAmplitudeMask.frame = frontAmplitudeView.bounds
    }
}

