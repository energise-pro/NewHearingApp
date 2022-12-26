//
//  LanguageTableViewCell.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

import UIKit

final class LanguageTableViewCell: UITableViewCell {

    // MARK: - Private Properties
    @IBOutlet private weak var languageLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(for locale: Locale) {
        languageLabel.text = locale.localizedString(forIdentifier: locale.identifier)?.capitalized
    }
}
