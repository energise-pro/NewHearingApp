import UIKit

final class HTranscriptListApViewController: PMUMainViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var placeholderContainerView: UIView!
    
    @IBOutlet private weak var placeholderTitleLabel: UILabel!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var dataSource: [[CellConfigurator]] = []
    private var filteredDataSource: [[CellConfigurator]] = []
    private var searchTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        [navigationItem.leftBarButtonItem].forEach { $0?.tintColor = AThemeServicesAp.shared.activeColor }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = "Transcripts".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        [navigationItem.leftBarButtonItem].forEach { $0?.tintColor = AThemeServicesAp.shared.activeColor }
        
        placeholderTitleLabel.text = "No transcriptions found".localized()
        searchBar.placeholder = "Search".localized() + "..."
        
        let cellNibs: [UIViewCellNib.Type] = [GTranscriptionTablViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
        
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: .zero, bottom: .zero, right: .zero)
    }
    
    private func configureDataSource() {
        dataSource = []
        filteredDataSource = []
        
        CTranscribServicesAp.shared.savedTranscripts = CTranscribServicesAp.shared.savedTranscripts.sorted(by: { $0.createdDate > $1.createdDate })
        dataSource = grouped(CTranscribServicesAp.shared.savedTranscripts)
        filteredDataSource = dataSource
        
        tableView.reloadData()
    }
    
    private func grouped(_ transcripts: [TranscribeModel]) -> [[CellConfigurator]] {
        var dataSource: [[CellConfigurator]] = []
        let groupedByDateDict = Dictionary(grouping: transcripts) {
            return Calendar.current.dateInterval(of: .month, for: Date(timeIntervalSince1970: $0.createdDate))?.start ?? Date.distantPast
        }
        groupedByDateDict.keys.sorted(by: { $0 > $1 }).forEach { key in
            guard let transcripts = groupedByDateDict[key] else {
                return
            }
            
            let cellConfigs = transcripts
                .compactMap { GTranscriptionTablViewCellModel(transcriptModel: $0, delegate: self) }
                .compactMap { GTranscriptionTablViewCellConfig(item: $0) }
            dataSource.append(cellConfigs)
        }
        return dataSource
    }
    
    private func searchTranscripts(with text: String) {
        guard !text.isEmpty else {
            configureDataSource()
            return
        }
        let filteredDataSource = CTranscribServicesAp.shared.savedTranscripts.filter { $0.title.lowercased().contains(text.lowercased()) }
        self.filteredDataSource = grouped(filteredDataSource)
        tableView.reloadData()
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
            KAppConfigServic.shared.analytics.track(action: .v2SavedTranscriptsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.search.rawValue])
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2SavedTranscriptsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    } 
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HTranscriptListApViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.isHidden = filteredDataSource.isEmpty
        placeholderContainerView.isHidden = !filteredDataSource.isEmpty
        return filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfig: CellConfigurator = filteredDataSource[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfig.identifier, for: indexPath)
        cellConfig.configure(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return filteredDataSource[indexPath.section][indexPath.row].height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return filteredDataSource[indexPath.section][indexPath.row].height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let timeInterval = (filteredDataSource[section].first?.getItem() as? GTranscriptionTablViewCellModel)?.transcriptModel.createdDate ?? Date().timeIntervalSince1970
        return Date(timeIntervalSince1970: timeInterval).toMonthWithYear().capitalizingFirstLetter()
    }
}

// MARK: - GTranscriptionTablViewCellDelegate
extension HTranscriptListApViewController: GTranscriptionTablViewCellDelegate {
    
    func didSelectTranscript(from cell: GTranscriptionTablViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), let transcriptModel = (filteredDataSource[indexPath.section][indexPath.row].getItem() as? GTranscriptionTablViewCellModel)?.transcriptModel else {
            return
        }
        searchBar.endEditing(true)
        AppsNavManager.shared.pushYTranscriptDetailApViewController(with: transcriptModel, and: self)
        
        KAppConfigServic.shared.analytics.track(action: .v2SavedTranscriptsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.transcript.rawValue])
    }
}

// MARK: - YTranscriptDetailApViewControllerDelegate
extension HTranscriptListApViewController: YTranscriptDetailApViewControllerDelegate {
    
    func didUpdateTranscript() {
        searchBar.text = ""
        configureDataSource()
    }
}

// MARK: - UISearchBarDelegate
extension HTranscriptListApViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchTranscripts(with: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTranscripts(with: searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTranscripts(with: searchText)
    }
}
