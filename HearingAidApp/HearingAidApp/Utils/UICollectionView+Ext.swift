//
//  UICollectionView+Ext.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(UINib(nibName: cellClass.identifier, bundle: nil),
                 forCellWithReuseIdentifier: cellClass.identifier)
    }
}
