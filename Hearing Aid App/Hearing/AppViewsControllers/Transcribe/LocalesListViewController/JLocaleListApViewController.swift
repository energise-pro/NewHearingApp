import UIKit

protocol JLocaleListApViewControllerDelegate: AnyObject {
    func didChangeLocale()
}

final class JLocaleListApViewController: PMUMainViewController {
    
    enum ScreenType {
        case transcribe
        case translateTo
        case translateFrom
        
        var analyticAction: GAppAnalyticActions {
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
    private weak var delegate: JLocaleListApViewControllerDelegate?
    private var filteredLanguages: [TranslationLanguage] = []
    
    // MARK: - Init
    init(screenType: ScreenType, delegate: JLocaleListApViewControllerDelegate?) {
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
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        let countLocales: Int
        var titleText: String? = nil
        switch screenType {
        case .transcribe:
            titleText = "Your language".localized()
            countLocales = CTranscribServicesAp.shared.supportedLocalesWithSelectedLocale.count
        case .translateTo:
            countLocales = BTranslServicesNew.shared.outputLanguages.count
        case .translateFrom:
            countLocales = BTranslServicesNew.shared.inputLanguages.count
        }
        title = titleText ?? "Available Languages %@".localized(with: ["\(countLocales)"])
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.appColor(.Red100)!
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        
        view.backgroundColor = UIColor.appColor(.Purple10)
        
        let cellNibs: [UIViewCellNib.Type] = [SettingTableViewCell.self]
        cellNibs.forEach { tableView.register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
    
    private func configureDataSource() {
        switch screenType {
        case .transcribe:
            self.dataSource = CTranscribServicesAp.shared.supportedLocalesWithSelectedLocale
                .compactMap { SettingTableViewCellModel(title: "\(Locale.current.localizedString(forIdentifier: $0.identifier)?.capitalized ?? "")", buttonTypes: [.rightButton], rightImage: UIImage(named: $0.identifier == CTranscribServicesAp.shared.selectedLocale ? "checkBoldIcon" : ""), rightTintColor: AThemeServicesAp.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        case .translateTo:
            filteredLanguages = BTranslServicesNew.shared.outputLanguages
                .filter { $0.rawValue != BTranslServicesNew.shared.inputLanguage.rawValue }
            self.dataSource = filteredLanguages
                .compactMap {
                    let isSelected = BTranslServicesNew.shared.outputLanguage == $0
                    let isDownloadingModel = BTranslServicesNew.shared.isLanguageDownloading($0)
                    let isDownloadedModel = BTranslServicesNew.shared.isLanguageDownloaded($0)
                    let subTitle = isDownloadingModel ? "Downloading".localized() : (isDownloadedModel ? "Downloaded".localized() : "Download Translation Model".localized())
                    let title = Locale.current.localizedString(forLanguageCode: $0.rawValue)?.capitalized ?? ""
                    let titleAttributedString = NSMutableAttributedString()
                    let buttonTypes: [SettingTableViewButtonType] = isDownloadingModel ? [.loader] : [.rightButton]
                    titleAttributedString.append(NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: isSelected ? AThemeServicesAp.shared.activeColor : UIColor.label]))
                    titleAttributedString.append(NSAttributedString(string: "\n\(subTitle)", attributes: [.font: UIFont.systemFont(ofSize: 10.0, weight: .regular), .foregroundColor: isSelected ? AThemeServicesAp.shared.activeColor : UIColor.label]))
                    return SettingTableViewCellModel(title: nil, attributedTitle: titleAttributedString, buttonTypes: buttonTypes, rightImage: UIImage(systemName: isDownloadedModel ? "checkmark" : "icloud.and.arrow.down"), rightTintColor: AThemeServicesAp.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        case .translateFrom:
            filteredLanguages = BTranslServicesNew.shared.inputLanguages
                .filter { $0.rawValue != BTranslServicesNew.shared.outputLanguage.rawValue }
            self.dataSource = filteredLanguages
                .compactMap {
                    let isSelected = BTranslServicesNew.shared.inputLanguage == $0
                    let isDownloadingModel = BTranslServicesNew.shared.isLanguageDownloading($0)
                    let isDownloadedModel = BTranslServicesNew.shared.isLanguageDownloaded($0)
                    let subTitle = isDownloadingModel ? "Downloading".localized() : (isDownloadedModel ? "Downloaded".localized() : "Download Translation Model".localized())
                    let title = Locale.current.localizedString(forLanguageCode: $0.rawValue)?.capitalized ?? ""
                    let titleAttributedString = NSMutableAttributedString()
                    let buttonTypes: [SettingTableViewButtonType] = isDownloadingModel ? [.loader] : [.rightButton]
                    titleAttributedString.append(NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: isSelected ? AThemeServicesAp.shared.activeColor : UIColor.label]))
                    titleAttributedString.append(NSAttributedString(string: "\n\(subTitle)", attributes: [.font: UIFont.systemFont(ofSize: 10.0, weight: .regular), .foregroundColor: isSelected ? AThemeServicesAp.shared.activeColor : UIColor.label]))
                    return SettingTableViewCellModel(title: nil, attributedTitle: titleAttributedString, buttonTypes: buttonTypes, rightImage: UIImage(systemName: isDownloadedModel ? "checkmark" : "icloud.and.arrow.down"), rightTintColor: AThemeServicesAp.shared.activeColor, delegate: self) }
                .compactMap { SettingTableViewCellConfig(item: $0) }
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JLocaleListApViewController: UITableViewDataSource, UITableViewDelegate {
    
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
extension JLocaleListApViewController: SettingTableViewCellDelegate {
    
    func didSelectButton(with type: SettingTableViewButtonType, from cell: SettingTableViewCell) {
        guard let indexRow = tableView.indexPath(for: cell)?.row else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch screenType {
        case .transcribe:
            CTranscribServicesAp.shared.changeLocale(on: CTranscribServicesAp.shared.supportedLocalesWithSelectedLocale[indexRow])
            configureDataSource()
            delegate?.didChangeLocale()
            KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeLanguage.rawValue])
        case .translateTo:
            let selectedLanguage = filteredLanguages[indexRow]
            if BTranslServicesNew.shared.isLanguageDownloaded(selectedLanguage) {
                BTranslServicesNew.shared.changeOutputLanguage(on: selectedLanguage)
                configureDataSource()
                delegate?.didChangeLocale()
                KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeLanguage.rawValue])
            } else {
                let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    KAppConfigServic.shared.analytics.track(action: self.screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.downloadLanguage.rawValue])
                    
                    BTranslServicesNew.shared.downloadModel(language: selectedLanguage) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            BTranslServicesNew.shared.changeOutputLanguage(on: selectedLanguage)
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
            if BTranslServicesNew.shared.isLanguageDownloaded(selectedLanguage) {
                BTranslServicesNew.shared.changeInputLanguage(on: selectedLanguage)
                configureDataSource()
                delegate?.didChangeLocale()
                KAppConfigServic.shared.analytics.track(action: screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.changeLanguage.rawValue])
            } else {
                let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    KAppConfigServic.shared.analytics.track(action: self.screenType.analyticAction, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.downloadLanguage.rawValue])
                    
                    BTranslServicesNew.shared.downloadModel(language: selectedLanguage) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            BTranslServicesNew.shared.changeInputLanguage(on: selectedLanguage)
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
