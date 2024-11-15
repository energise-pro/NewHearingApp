//
//  NewSettingTableViewEmptyCell.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 14.11.2024.
//

import UIKit

struct NewSettingTableViewEmptyCellModel { }

typealias NewSettingTableViewEmptyCellConfig = АViewCellConfig<NewSettingTableViewEmptyCell, NewSettingTableViewEmptyCellModel>

final class NewSettingTableViewEmptyCell: UITableViewCell, HConfigCellProtocol, UIViewCellNib {

    typealias DataType = NewSettingTableViewEmptyCellModel
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(data: DataType) {
        
    }
}

