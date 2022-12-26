//
//  String+Ext.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
