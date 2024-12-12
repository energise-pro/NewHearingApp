import UIKit
import JXPageControl

final class PaywallCarouselView: UIView, UIScrollViewDelegate {
    
    enum FeaturesPage1Type: Int, CaseIterable {
        case volumeBoost
        case noiseElimination
        case soundCustomization
        
        var image: UIImage {
            switch self {
            case .volumeBoost:
                return UIImage(named: "featuresBoostIcon")!
            case .noiseElimination:
                return UIImage(named: "featuresNoiseIcon")!
            case .soundCustomization:
                return UIImage(named: "featuresSetupIcon")!
            }
        }
        
        var title: String {
            switch self {
            case .volumeBoost:
                return "Super Volume Boost".localized()
            case .noiseElimination:
                return "Noise Elimination".localized()
            case .soundCustomization:
                return "Full Sound Customization".localized()
            }
        }
    }
    
    enum FeaturesPage2Type: Int, CaseIterable {
        case transcription
        case translation
        case typeLarge
        
        var image: UIImage {
            switch self {
            case .transcription:
                return UIImage(named: "featuresTranscriptionIcon")!
            case .translation:
                return UIImage(named: "featuresTranslationIcon")!
            case .typeLarge:
                return UIImage(named: "featuresTypeIcon")!
            }
        }
        
        var title: String {
            switch self {
            case .transcription:
                return "Real-time Transcription".localized()
            case .translation:
                return "Real-time Translation (Offline)".localized()
            case .typeLarge:
                return "Type Large".localized()
            }
        }
    }
    
    // MARK: - Private properties
    private let scrollView = UIScrollView()
    private let stackView1 = UIStackView()
    private let stackView2 = UIStackView()
    private let pageControl = JXPageControlExchange()
    private var timer: Timer?
    private var currentIndex = 0
    private let pageCount = 2
    private let autoScrollDelay: TimeInterval = 5.0
    private var autoScrollResumptionWorkItem: DispatchWorkItem?
    
    // MARK: - Deinit
    deinit {
        timer?.invalidate()
        autoScrollResumptionWorkItem?.cancel()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        setupScrollView()
        setupStackViews()
        setupPageControl()
        startAutoScroll()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])
    }
    
    private func setupStackViews() {
        let stackContainer = UIStackView(arrangedSubviews: [stackView1, stackView2])
        stackContainer.axis = .horizontal
        stackContainer.distribution = .fillEqually
        stackContainer.spacing = 0
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackContainer)
        
        NSLayoutConstraint.activate([
            stackContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            stackContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: CGFloat(pageCount))
        ])
        
        [stackView1, stackView2].forEach { stackView in
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.spacing = 12
        }
        
        for type in FeaturesPage1Type.allCases {
            let paddedView = createPaddedRadialGradientView(
                text: type.title,
                image: type.image
            )
            stackView1.addArrangedSubview(paddedView)
        }
        
        for type in FeaturesPage2Type.allCases {
            let paddedView = createPaddedRadialGradientView(
                text: type.title,
                image: type.image
            )
            stackView2.addArrangedSubview(paddedView)
        }
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        pageControl.activeSize = CGSize(width: 28, height: 8)
        pageControl.inactiveSize = CGSize(width: 8, height: 8)
        pageControl.inactiveSize = CGSize(width: 8, height: 8)
        pageControl.activeColor = UIColor.appColor(.Red100)!
        pageControl.inactiveColor = UIColor.appColor(.Red100)!.withAlphaComponent(0.3)
        pageControl.columnSpacing = 0
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func createPaddedRadialGradientView(text: String, image: UIImage?) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientView = RadialGradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.configure(withText: text, image: image)
        
        containerView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            gradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            gradientView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        return containerView
    }
    
    // MARK: - AutoScroll Logic
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resumeAutoScroll() {
        autoScrollResumptionWorkItem?.cancel()
        autoScrollResumptionWorkItem = DispatchWorkItem { [weak self] in
            self?.startAutoScroll()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + autoScrollDelay, execute: autoScrollResumptionWorkItem!)
    }
    
    private func scrollToNextPage() {
        currentIndex += 1
        if currentIndex >= pageCount {
            currentIndex = 0
        }
        let offset = CGPoint(x: CGFloat(currentIndex) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = page
        currentIndex = page
        resumeAutoScroll()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = page
    }
}
