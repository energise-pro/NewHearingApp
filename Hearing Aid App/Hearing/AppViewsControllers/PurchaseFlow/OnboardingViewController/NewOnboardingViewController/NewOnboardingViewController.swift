//
//  NewOnboardingViewController.swift
//  Hearing Aid App
//
//

import UIKit
import JXPageControl

final class NewOnboardingViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var pageControl: JXPageControlExchange!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomViewTopImage: UIImageView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    //MARK: - Properties
    private var currentIndex: Int = .zero
    private let defaultBottomViewHeight: CGFloat = 334.0
    private let defaultBottomViewHeightWithImage: CGFloat = 402.0
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        KAppConfigServic.shared.analytics.track(.obSeen, with: [
            "screen_number": (currentIndex + 1).toString() ?? "",
            "ob_version" : "1"
        ])
        configureViewController()
        configureCollectionView()
        configureDataSource()
        configurePageControl()
        configureBottomControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        topConstraintPageControlView.constant = max(.appHeight * 0.575, 340)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KAppConfigServic.shared.requestIDFA{}
    }
    
    //MARK: - Functions
    private func configureViewController() {
        bottomViewTopImage.isHidden = true
        
        pageControl.numberOfPages = NewOnboardingPagesModel.allCases.count
        pageControl.activeSize = CGSize(width: 28, height: 8)
        pageControl.inactiveSize = CGSize(width: 8, height: 8)
        pageControl.inactiveSize = CGSize(width: 8, height: 8)
        pageControl.activeColor = UIColor.appColor(.Red100)!
        pageControl.inactiveColor = UIColor.appColor(.Red100)!.withAlphaComponent(0.3)
        pageControl.columnSpacing = 0
        
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor.appColor(.White100)
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = UIColor.appColor(.White100)
        
        bottomButton.layer.masksToBounds = true
        bottomButton.layer.cornerRadius = 28
        
        bottomButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    private func configureCollectionView() {
        let cellsName = ["NewOnboardPageCollectionViewCell"]
        cellsName.forEach { cellName in
            collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        DataSource.dataSource = []
        NewOnboardingPagesModel.allCases.forEach { onboardingPage in
            let page = NewOnbordingPageModelCollectionViewCell(onboardingType: onboardingPage)
            DataSource.dataSource.append(page)
        }
    }
    
    private func configureBottomControl(newHeight: CGFloat) {
        let page = DataSource.dataSource[currentIndex]
        
        let titleText = NSMutableAttributedString(string: page.onboardingType.title.localized(), attributes: [
            .paragraphStyle: createParagraphStyle(lineHeightMultiple: 1.26)
        ])
        
        let subtitleText = NSMutableAttributedString(string: page.onboardingType.description.localized(), attributes: [
            .paragraphStyle: createParagraphStyle(lineHeightMultiple: 1.18)
        ])
        
        UIView.transition(with: titleLabel, duration: 0.35, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            self.titleLabel.attributedText = titleText
            self.titleLabel.textAlignment = .center
        }, completion: nil)

        UIView.transition(with: subtitleLabel, duration: 0.35, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            self.subtitleLabel.attributedText = subtitleText
            self.subtitleLabel.textAlignment = .center
        }, completion: { _ in
            self.bottomViewHeight.constant = newHeight
            self.bottomViewTopImage.alpha = 0
            self.bottomViewTopImage.isHidden = false
            
            UIView.animate(withDuration: 0.35, animations: {
                self.view.layoutIfNeeded()
                self.bottomViewTopImage.alpha = newHeight == self.defaultBottomViewHeightWithImage ? 1 : 0
            })
        })
    }
    
    private func configureBottomControl() {
        let page = DataSource.dataSource[currentIndex]
        
        let titleText = NSMutableAttributedString(string: page.onboardingType.title.localized(), attributes: [
            .paragraphStyle: createParagraphStyle(lineHeightMultiple: 1.26)
        ])
        
        let subtitleText = NSMutableAttributedString(string: page.onboardingType.description.localized(), attributes: [
            .paragraphStyle: createParagraphStyle(lineHeightMultiple: 1.18)
        ])
        
        // Animate title label text change
        UIView.transition(with: titleLabel, duration: 0.35, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            self.titleLabel.attributedText = titleText
            self.titleLabel.textAlignment = .center
        }, completion: nil)
        
        // Animate subtitle label text change
        UIView.transition(with: subtitleLabel, duration: 0.35, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            self.subtitleLabel.attributedText = subtitleText
            self.subtitleLabel.textAlignment = .center
        }, completion: nil)
    }
    
    private func configurePageControl() {
        pageControl.currentPage = currentIndex
    }
    
    //MARK: - Functions
    private func setPageActive(for index: Int) {
        currentIndex = index
        
        configurePageControl()
        if currentIndex == 2 {
            configureBottomControl(newHeight: defaultBottomViewHeightWithImage)
        } else {
            configureBottomControl(newHeight: defaultBottomViewHeight)
        }
        
        KAppConfigServic.shared.analytics.track(.obSeen, with: [
            "screen_number": (currentIndex + 1).toString() ?? "",
            "ob_version" : "1"
        ])
    }
    
    //MARK: - Actions
    @IBAction func onBottomButtonTap(_ sender: Any) {
        TapticEngine.impact.feedback(.medium)
        
        let newCurrentIndex = currentIndex + 1
        KAppConfigServic.shared.analytics.track(.obPassed, with: [
            "screen_number": newCurrentIndex.toString() ?? "",
            "ob_version" : "1"
        ])
        currentIndex == NewOnboardingPagesModel.allCases.count - 1 ? Void() : collectionView.scrollToItem(at: IndexPath(row: newCurrentIndex, section: 0), at: .centeredHorizontally, animated: true)
        currentIndex == NewOnboardingPagesModel.allCases.count - 1 ? AppsNavManager.shared.setTabBarAsRootViewController() : Void()
        
        if newCurrentIndex < NewOnboardingPagesModel.allCases.count {
            currentIndex = newCurrentIndex
            setPageActive(for: currentIndex)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension NewOnboardingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataSource.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewOnboardPageCollectionViewCell", for: indexPath) as! NewOnboardPageCollectionViewCell
        cell.configureCell(model: DataSource.dataSource[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension NewOnboardingViewController: UICollectionViewDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentIndex = Int((scrollView.contentOffset.x / .appWidth).rounded(.toNearestOrAwayFromZero))
//        setPageActive(for: currentIndex)
//    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewOnboardingViewController: UICollectionViewDelegateFlowLayout {
    
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

extension NewOnboardingViewController {
    
    private func createParagraphStyle(lineHeightMultiple: CGFloat) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        return paragraphStyle
    }
    
    private func updateBottomViewHeight(to newHeight: CGFloat) {
        // Update the constraint constant
        bottomViewHeight.constant = newHeight
        
        // Animate the layout change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

private struct DataSource {
    
    static var dataSource = [NewOnbordingPageModelCollectionViewCell]()
}
