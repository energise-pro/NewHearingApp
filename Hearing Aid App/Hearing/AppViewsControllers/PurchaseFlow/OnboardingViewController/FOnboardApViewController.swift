import UIKit
import AVFoundation

final class FOnboardApViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var topConstraintPageControlView: NSLayoutConstraint!
    
    //MARK: - Properties
    private var currentIndex: Int = .zero
    private var playedIndexPath: IndexPath?
    private var audioPlayer: AVPlayer?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        KAppConfigServic.shared.analytics.track(.v2Onboarding, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        configureCollectionView()
        configureDataSource()
        pageControl.numberOfPages = TOnboardHvTabs.allCases.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topConstraintPageControlView.constant = max(.appHeight * 0.575, 340)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? JOnbrdCollectViewCell)?.setDefaultStatesForButtons()
        
        KAppConfigServic.shared.requestIDFA{}
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        coordinator.animate { [weak self] _ in
            self?.collectionView.reloadData()
            self?.topConstraintPageControlView.constant = max(.appHeight * 0.575, 340)
            self?.collectionView.scrollToItem(at: IndexPath(row: self?.currentIndex ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Functions
    private func configureCollectionView() {
        let cellsName = ["JOnbrdCollectViewCell", "GOnbBSpeechViewCell"]
        cellsName.forEach { cellName in
            collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        configurePageControl()
        
        DataSource.dataSource = []
        TOnboardHvTabs.allCases.forEach { onboardingTab in
            let tab = GOnboModelCollectionViewCell(onboardingType: onboardingTab, delegate: self)
            DataSource.dataSource.append(tab)
        }
    }

    private func setPageActive(for index: Int) {
        guard currentIndex != index, currentIndex < TOnboardHvTabs.allCases.count else {
            return
        }
        
        currentIndex = index
        
        let transcribeCell = collectionView.cellForItem(at: IndexPath(item: TOnboardHvTabs.speachRecognition.rawValue, section: 0)) as? GOnbBSpeechViewCell
        let translateCell = collectionView.cellForItem(at: IndexPath(item: TOnboardHvTabs.speechTranslate.rawValue, section: 0)) as? GOnbBSpeechViewCell
        currentIndex == TOnboardHvTabs.speachRecognition.rawValue ? transcribeCell?.startTypographyAnimation() : transcribeCell?.pauseTypographyAnimation()
        currentIndex == TOnboardHvTabs.speechTranslate.rawValue ? translateCell?.startTypographyAnimation() : translateCell?.pauseTypographyAnimation()
        
        if let indexPath = playedIndexPath {
            audioPlayer?.pause()
            let onboardingCell = collectionView.cellForItem(at: indexPath) as? JOnbrdCollectViewCell
            onboardingCell?.setDefaultStatesForButtons()
        }
        
        configurePageControl()
//        KAppConfigServic.shared.analytics.track(.v2Onboarding, with: [GAppAnalyticActions.action.rawValue: "scroll_on_\(index)"])
    }
    
    private func configurePlayer(audioPath: String) {
        guard let url = Bundle.main.url(forResource: audioPath, withExtension: "mp3") else { return }
        let item = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: item)
        audioPlayer?.play()
        
        if !SAudioKitServicesAp.shared.connectedHeadphones {
            SAudioKitServicesAp.shared.overrideOutputAudioPort(on: .speaker)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    @objc private func playerDidFinishPlaying(sender: Notification) {
        guard let playedIndexPath = playedIndexPath else {
            return
        }
        let playerURLAsset = (sender.object as? AVPlayerItem)?.asset as? AVURLAsset
        let isBeforeItem = playerURLAsset?.url.lastPathComponent == "\(TOnboardHvTabs.allCases[safe: playedIndexPath.row]?.beforeRingtonePath ?? "").mp3"
        (collectionView.cellForItem(at: playedIndexPath) as? JOnbrdCollectViewCell)?.updateStateButton(asActive: false, button: .after)
        isBeforeItem ? (collectionView.cellForItem(at: playedIndexPath) as? JOnbrdCollectViewCell)?.triggerAfterButtonAction() : Void()
    }
    
    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = AThemeServicesAp.shared.activeColor.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = AThemeServicesAp.shared.activeColor
        pageControl.currentPage = currentIndex
    }
}

//MARK: - JOnbrdCollectViewCellDelegate
extension FOnboardApViewController: JOnbrdCollectViewCellDelegate {
    
    func tapBeforeButton(from cell: JOnbrdCollectViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let audioPath = TOnboardHvTabs.allCases[safe: indexPath.row]?.beforeRingtonePath else {
            return
        }
        TapticEngine.impact.feedback(.medium)
//        KAppConfigServic.shared.analytics.track(.v2Onboarding, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.before.rawValue)_\(currentIndex)"])
        playedIndexPath = indexPath
        configurePlayer(audioPath: audioPath)
    }
    
    func tapAfterButton(from cell: JOnbrdCollectViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let audioPath = TOnboardHvTabs.allCases[safe: indexPath.row]?.afterRingtonePath else {
            return
        }
        TapticEngine.impact.feedback(.medium)
//        KAppConfigServic.shared.analytics.track(.v2Onboarding, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.after.rawValue)_\(currentIndex)"])
        playedIndexPath = indexPath
        configurePlayer(audioPath: audioPath)
    }
    
    func tapContinueButton() {
        TapticEngine.impact.feedback(.medium)
//        KAppConfigServic.shared.analytics.track(.v2Onboarding, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.continue.rawValue)_\(currentIndex)"])
        audioPlayer?.pause()
        currentIndex == TOnboardHvTabs.allCases.count - 1 ? Void() : collectionView.scrollToItem(at: IndexPath(row: currentIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
        currentIndex == TOnboardHvTabs.allCases.count - 1 ? AppsNavManager.shared.setTabBarAsRootViewController() : Void()
        configurePageControl()
    }
}

//MARK: - UICollectionViewDataSource
extension FOnboardApViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataSource.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case TOnboardHvTabs.speachRecognition.rawValue, TOnboardHvTabs.speechTranslate.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GOnbBSpeechViewCell", for: indexPath) as! GOnbBSpeechViewCell
            cell.configureCell(model: DataSource.dataSource[indexPath.row])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JOnbrdCollectViewCell", for: indexPath) as! JOnbrdCollectViewCell
            cell.configureCell(model: DataSource.dataSource[indexPath.row])
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension FOnboardApViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int((scrollView.contentOffset.x / .appWidth).rounded(.toNearestOrAwayFromZero))
        setPageActive(for: currentIndex)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FOnboardApViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

private struct DataSource {
    
    static var dataSource = [GOnboModelCollectionViewCell]()
}
