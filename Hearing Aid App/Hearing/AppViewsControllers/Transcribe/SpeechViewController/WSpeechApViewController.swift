import UIKit

final class WSpeechApViewController: PMUMainViewController {

    enum BottomButtonType: Int, CaseIterable {
        case type
        case transcribe
        case translate
        
        var image: UIImage? {
            switch self {
            case .translate:
                return CAppConstants.Images.speechTranslateIcon
            case .type:
                return CAppConstants.Images.speechTypeIcon
            case .transcribe:
                return CAppConstants.Images.speechTranscribeIcon
            }
        }
        
        var title: String {
            switch self {
            case .translate:
                return "Translate".localized()
            case .type:
                return "Type".localized()
            case .transcribe:
                return "Transcribe".localized()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var bottomView: UIView!
    
    @IBOutlet private var bottomImageViews: [UIImageView]!
    @IBOutlet private var bottomLabels: [UILabel]!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var placeholderContainerView: UIView!
    @IBOutlet private weak var placeholderTitleLabel: UILabel!
    
    private var dataSource: [[CellConfigurator]] = []
    private var filteredDataSource: [[CellConfigurator]] = []
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        updateMainColors()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        
        titleLabel.textColor = UIColor.appColor(.Purple100)
        titleLabel.text = "Transcripts".localized()
        
        infoImageView.image = CAppConstants.Images.icInstructionInfo
        
        bottomView.layer.cornerRadius = 12
        bottomView.layer.cornerCurve = .continuous
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.backgroundColor = UIColor.appColor(.Purple100)
        
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
        }
        
        searchBar.placeholder = "Search".localized()
        searchBar.overrideUserInterfaceStyle = .light
        
        let cellNibs: [UIViewCellNib.Type] = [GTranscriptionTablViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: .zero, bottom: .zero, right: .zero)
        tableView.backgroundColor = UIColor.appColor(.Purple10)
        
        updateMainColors()
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
    
    private func updateMainColors() {
        [infoImageView].forEach { $0?.tintColor = AThemeServicesAp.shared.activeColor }
    }
    
    private func searchTranscripts(with text: String) {
        guard !text.isEmpty else {
            configureDataSource()
            return
        }
        let filteredDataSource = CTranscribServicesAp.shared.savedTranscripts.filter { $0.title.lowercased().contains(text.lowercased()) }
        self.filteredDataSource = grouped(filteredDataSource)
        tableView.reloadData()
        
//        searchTimer?.invalidate()
//        searchTimer = Timer.scheduledTimer(withTimeInterval: GAppAnalyticActions.delaySliderInterval, repeats: false) { _ in
//            KAppConfigServic.shared.analytics.track(action: .v2SavedTranscriptsScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.search.rawValue])
//        }
    }
    
    // MARK: - IBActions
    @IBAction private func bottomButtonsAction(_ sender: UIButton) {
        guard let buttonType = BottomButtonType(rawValue: sender.tag) else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch buttonType {
        case .translate:
            AppsNavManager.shared.presentJTranslatApViewController()
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.translate.rawValue])
        case .type:
            AppsNavManager.shared.presentDTypeTextApViewController()
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.type.rawValue])
        case .transcribe:
            AppsNavManager.shared.presentUTranscribApViewController(and: self)
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.transcribe.rawValue])
        }
    }
    
    @IBAction private func bookmarkButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentHTranscriptListApViewController()
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saved.rawValue])
    }
    
    @IBAction private func instructionButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        //AppsNavManager.shared.presentVideoFInstructApViewController(with: CAppConstants.URLs.transcrabeInstructions)
        AppsNavManager.shared.presentCustomVideoFInstructApViewController()
    }

    @IBAction func infoButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentTranscriptionInstructionViewController()
        //        KAppConfigServic.shared.analytics.track(action: .v2HearingScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.info.rawValue])
    }
}

// MARK: - UISearchBarDelegate
extension WSpeechApViewController: UISearchBarDelegate {
    
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension WSpeechApViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.isHidden = filteredDataSource.isEmpty
        placeholderContainerView.isHidden = !filteredDataSource.isEmpty
        var placeholderTitleText = CTranscribServicesAp.shared.isSavedFirstTranscripts ? "No transcripts match your search – try a different keyword".localized() : "No saved transcripts".localized()
        if CTranscribServicesAp.shared.isShowGetStartedView {
            placeholderTitleText = "No saved transcripts yet".localized()
        }
        placeholderTitleLabel.text = placeholderTitleText
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let timeInterval = (filteredDataSource[section].first?.getItem() as? GTranscriptionTablViewCellModel)?.transcriptModel.createdDate ?? Date().timeIntervalSince1970
//        return Date(timeIntervalSince1970: timeInterval).toMonthWithYear().capitalizingFirstLetter()
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let timeInterval = (filteredDataSource[section].first?.getItem() as? GTranscriptionTablViewCellModel)?.transcriptModel.createdDate ?? Date().timeIntervalSince1970
        let label = UILabel()
        label.contentMode = .top
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.appColor(.Purple100)
        label.text = Date(timeIntervalSince1970: timeInterval).toMonthWithYear().uppercased()
        return label
    }
}

// MARK: - GTranscriptionTablViewCellDelegate
extension WSpeechApViewController: GTranscriptionTablViewCellDelegate {
    
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
extension WSpeechApViewController: YTranscriptDetailApViewControllerDelegate, UTranscribApViewControllerDelegate {
    
    func didUpdateTranscript() {
        searchBar.text = ""
        configureDataSource()
    }
}
