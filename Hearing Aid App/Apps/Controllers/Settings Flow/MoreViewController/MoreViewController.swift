import UIKit

final class MoreViewController: PMBaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "More".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = ThemeService.shared.activeColor
        
        tableView.contentInset = UIEdgeInsets(top: 25.0, left: .zero, bottom: .zero, right: .zero)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self, SimpleSegmentTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        let segmentCellModel = SimpleSegmentTableViewCellModel(mainTitle: "Main Screen".localized(), titles: [VTabBarsViewController.TabBarButton.hearing.title, VTabBarsViewController.TabBarButton.transcribe.title], selectedIndex: AppConfigService.shared.settings.mainScreen, delegate: self)
        let segmentCellConfig = SimpleSegmentTableViewCellConfig(item: segmentCellModel)
        
        let manageCellModel = SettingTableViewCellModel(title: "Manage subscriptions".localized(), buttonTypes: [.rightButton], delegate: self)
        let manageCellConfig = SettingTableViewCellConfig(item: manageCellModel)
        
        let cancelSubscriptionCellModel = SettingTableViewCellModel(title: "Cancel subscription".localized(), buttonTypes: [.rightButton], delegate: self)
        let cancelSubscriptionCellConfig = SettingTableViewCellConfig(item: cancelSubscriptionCellModel)
        
        dataSource = [segmentCellConfig, manageCellConfig, cancelSubscriptionCellConfig]
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfigService.shared.analytics.track(action: .v2MoreScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MoreViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfig: CellConfigurator = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfig.identifier, for: indexPath)
        cellConfig.configure(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].height ?? UITableView.automaticDimension
    }
}

// MARK: - SettingTableViewCellDelegate
extension MoreViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch indexRow {
        case 1: // Manage subscription
            NavigationManager.shared.presentManageSubscription()
            
            AppConfigService.shared.analytics.track(.v2MoreScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.manageSubscriptions.rawValue])
        case 2: // Cancel subscription
            NavigationManager.shared.presentCancelSubscriptionViewController()
            
            AppConfigService.shared.analytics.track(.v2MoreScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.cancelSubscription.rawValue])
        default:
            break
        }
    }
}

// MARK: - SimpleSegmentTableViewCellDelegate
extension MoreViewController: SimpleSegmentTableViewCellDelegate {
    
    func didSelectSegment(with index: Int, from cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              var cellModel = dataSource[safe: indexPath.row]?.getItem() as? SimpleSegmentTableViewCellModel,
              AppConfigService.shared.settings.mainScreen != index else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        AppConfigService.shared.settings.mainScreen = index
        
        cellModel.selectedIndex = MicrophoneType.selectedMicrophone.rawValue
        let cellConfig = SimpleSegmentTableViewCellConfig(item: cellModel)
        dataSource[indexPath.row] = cellConfig
        
        NavigationManager.shared.VTabBarsViewController?.reconfigureUI()
        
        let selectedMainScreenString = String(describing: VTabBarsViewController.TabBarButton(rawValue: index)!)
        AppConfigService.shared.analytics.track(.v2MoreScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.changeMainScreen.rawValue)_\(selectedMainScreenString)"])
    }
}
