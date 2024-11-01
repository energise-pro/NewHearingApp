import UIKit

protocol LocalesListViewControllerDelegate: AnyObject {
    func didChangeLocale()
}

final class LocalesListViewController: PMBaseViewController {
    
    enum ScreenType {
        case transcribe
        case translateTo
        case translateFrom
        
        var analyticAction: AnalyticsAction {
            switch self {
            case .transcribe:
                return .v2TranscribeLanguagesScreen
            case .translateTo:
                return .v2TranslateToLanguagesScreen
            case .translateFrom:
                return .v2TranslateFromLanguagesScreen
            }
        }
    }

    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: [CellConfigurator] = []
    
    private var screenType: ScreenType
    private weak var delegate: LocalesListViewControllerDelegate?
    private var filteredLanguages: [TranslationLanguage] = []
    
    // MARK: - Init
    init(screenType: ScreenType, delegate: LocalesListViewControllerDelegate?) {
        self.screenType = screenType
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let countLocales: Int
        switch screenType {
        case .transcribe:
            countLocales = TranscribeService.shared.supportedLocales.count
        case .translateTo:
            countLocales = TranslateService.shared.outputLanguages.count
        case .translateFrom:
            countLocales = TranslateService.shared.inputLanguages.count
        }
        title = "Available Languages %@".localized(with: ["\(countLocales)"])
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        view.backgroundColor = UIColor.appColor(.UnactiveButton_3)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        switch screenType {
        case .transcribe:
            self.dataSource = TranscribeService.shared.supportedLocales
                .compactMap { SettingTableViewCellModel(title: "\(Locale.current.localizedString(forIdentifier: $0.identifier)?.capitalized ?? "")", buttonTypes: [.rightButton], rightImage: UIImage(systemName: $0.identifier == TranscribeService.shared.selectedLocale ? "checkmark" : ""), rightTintColor: ThemeService.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        case .translateTo:
            filteredLanguages = TranslateService.shared.outputLanguages
                .filter { $0.rawValue != TranslateService.shared.inputLanguage.rawValue }
            self.dataSource = filteredLanguages
                .compactMap {
                    let isSelected = TranslateService.shared.outputLanguage == $0
                    let isDownloadingModel = TranslateService.shared.isLanguageDownloading($0)
                    let isDownloadedModel = TranslateService.shared.isLanguageDownloaded($0)
                    let subTitle = isDownloadingModel ? "Downloading".localized() : (isDownloadedModel ? "Downloaded".localized() : "Download Translation Model".localized())
                    let title = Locale.current.localizedString(forLanguageCode: $0.rawValue)?.capitalized ?? ""
                    let titleAttributedString = NSMutableAttributedString()
                    let buttonTypes: [SettingTableViewButtonType] = isDownloadingModel ? [.loader] : [.rightButton]
                    titleAttributedString.append(NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: isSelected ? ThemeService.shared.activeColor : UIColor.label]))
                    titleAttributedString.append(NSAttributedString(string: "\n\(subTitle)", attributes: [.font: UIFont.systemFont(ofSize: 10.0, weight: .regular), .foregroundColor: isSelected ? ThemeService.shared.activeColor : UIColor.label]))
                    return SettingTableViewCellModel(title: nil, attributedTitle: titleAttributedString, buttonTypes: buttonTypes, rightImage: UIImage(systemName: isDownloadedModel ? "checkmark" : "icloud.and.arrow.down"), rightTintColor: ThemeService.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        case .translateFrom:
            filteredLanguages = TranslateService.shared.inputLanguages
                .filter { $0.rawValue != TranslateService.shared.outputLanguage.rawValue }
            self.dataSource = filteredLanguages
                .compactMap {
                    let isSelected = TranslateService.shared.inputLanguage == $0
                    let isDownloadingModel = TranslateService.shared.isLanguageDownloading($0)
                    let isDownloadedModel = TranslateService.shared.isLanguageDownloaded($0)
                    let subTitle = isDownloadingModel ? "Downloading".localized() : (isDownloadedModel ? "Downloaded".localized() : "Download Translation Model".localized())
                    let title = Locale.current.localizedString(forLanguageCode: $0.rawValue)?.capitalized ?? ""
                    let titleAttributedString = NSMutableAttributedString()
                    let buttonTypes: [SettingTableViewButtonType] = isDownloadingModel ? [.loader] : [.rightButton]
                    titleAttributedString.append(NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: isSelected ? ThemeService.shared.activeColor : UIColor.label]))
                    titleAttributedString.append(NSAttributedString(string: "\n\(subTitle)", attributes: [.font: UIFont.systemFont(ofSize: 10.0, weight: .regular), .foregroundColor: isSelected ? ThemeService.shared.activeColor : UIColor.label]))
                    return SettingTableViewCellModel(title: nil, attributedTitle: titleAttributedString, buttonTypes: buttonTypes, rightImage: UIImage(systemName: isDownloadedModel ? "checkmark" : "icloud.and.arrow.down"), rightTintColor: ThemeService.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LocalesListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension LocalesListViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch screenType {
        case .transcribe:
            TranscribeService.shared.changeLocale(on: TranscribeService.shared.supportedLocales[indexRow])
            configureDataSource()
            delegate?.didChangeLocale()
            AppConfiguration.shared.analytics.track(action: screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeLanguage.rawValue])
        case .translateTo:
            let selectedLanguage = filteredLanguages[indexRow]
            if TranslateService.shared.isLanguageDownloaded(selectedLanguage) {
                TranslateService.shared.changeOutputLanguage(on: selectedLanguage)
                configureDataSource()
                delegate?.didChangeLocale()
                AppConfiguration.shared.analytics.track(action: screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeLanguage.rawValue])
            } else {
                let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    AppConfiguration.shared.analytics.track(action: self.screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.downloadLanguage.rawValue])
                    
                    TranslateService.shared.downloadModel(language: selectedLanguage) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            TranslateService.shared.changeOutputLanguage(on: selectedLanguage)
                        }
                        self.configureDataSource()
                        self.delegate?.didChangeLocale()
                    }
                    self.configureDataSource()
                }
                let noAction = UIAlertAction(title: "No".localized(), style: .default)
                presentAlertPM(title: "Do you want to download model?".localized(with: [Locale.current.localizedString(forLanguageCode: selectedLanguage.rawValue) ?? ""]), message: "", actions: [noAction, yesAction])
            }
        case .translateFrom:
            let selectedLanguage = filteredLanguages[indexRow]
            if TranslateService.shared.isLanguageDownloaded(selectedLanguage) {
                TranslateService.shared.changeInputLanguage(on: selectedLanguage)
                configureDataSource()
                delegate?.didChangeLocale()
                AppConfiguration.shared.analytics.track(action: screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeLanguage.rawValue])
            } else {
                let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    AppConfiguration.shared.analytics.track(action: self.screenType.analyticAction, with: [AnalyticsAction.action.rawValue: AnalyticsAction.downloadLanguage.rawValue])
                    
                    TranslateService.shared.downloadModel(language: selectedLanguage) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            TranslateService.shared.changeInputLanguage(on: selectedLanguage)
                        }
                        self.configureDataSource()
                        self.delegate?.didChangeLocale()
                    }
                    self.configureDataSource()
                }
                let noAction = UIAlertAction(title: "No".localized(), style: .default)
                presentAlertPM(title: "Do you want to download model?".localized(with: [Locale.current.localizedString(forLanguageCode: selectedLanguage.rawValue) ?? ""]), message: "", actions: [noAction, yesAction])
            }
        }
    }
}
