import UIKit

final class VAmplitViewController: UIViewController, Gradientable {

    @IBInspectable var isHorizontal: Bool = false {
        didSet {
            if isViewLoaded {
                view.transform = isHorizontal ? CGAffineTransform.init(rotationAngle: .pi/2) : .identity
            }
        }
    }

    //back Amplitude view
    private let backgrounAmplitudeView = VSringlerView()
    private let backgrounAmplitudeMask = CSringFImageView(image: #imageLiteral(resourceName: "volume"))
    let gradient: CAGradientLayer = CAGradientLayer()

    //front Amplitude view
    private let frontAmplitudeView = VSringlerView()
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
        addGradientOn(view: backgrounAmplitudeView, at: 0, colors: Theme.current.gradientColors)

        backgrounAmplitudeView.backgroundColor = .clear
        backgrounAmplitudeMask.contentMode = .scaleToFill
        backgrounAmplitudeView.mask = backgrounAmplitudeMask
        view.addSubview(backgrounAmplitudeView)

        frontAmplitudeMask.contentMode = .scaleToFill

        frontAmplitudeView.mask = frontAmplitudeMask

        view.addSubview(frontAmplitudeView)

        frontAmplitudeView.alpha = 0
        backgrounAmplitudeView.alpha = 0
//
//        let displayLink = CADisplayLink(target: self, selector: #selector(updateAmplitude))
//        displayLink.add(to: .current, forMode: .common)
        
        AudioKitService.shared.didChangeAmplitudeCompletion = { [weak self] value in
            self?.updateAmplitude(on: value)
        }
        animateAppearance()
    }

    func animateAppearance() {
        frontAmplitudeView.alpha = 0
        backgrounAmplitudeView.alpha = 0
        frontAmplitudeView.animate(name:"pop")
        backgrounAmplitudeView.animate(name:"pop")
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
        backgrounAmplitudeView.tintColor = Theme.buttonActiveColor
        frontAmplitudeView.backgroundColor = Theme.buttonInactiveColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFrame()
    }

    func updateFrame() {
        backgrounAmplitudeView.frame = view.bounds
        backgrounAmplitudeMask.frame = backgrounAmplitudeView.bounds
        frontAmplitudeView.frame = backgrounAmplitudeView.frame
        frontAmplitudeMask.frame = frontAmplitudeView.bounds
    }
}

