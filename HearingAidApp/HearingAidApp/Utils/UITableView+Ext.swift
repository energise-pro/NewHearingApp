//
//  UITableView+Ext.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(UINib(nibName: cellClass.identifier, bundle: nil),
                 forCellReuseIdentifier: cellClass.identifier)
    }
}

