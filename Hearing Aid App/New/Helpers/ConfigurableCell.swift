import UIKit

protocol ConfigurableCellProtocol {
    associatedtype DataType
    
    // MARK: - Properties
    static var identifier: String { get }
    
    // MARK: - Public methods
    func configure(data: DataType)
}

protocol CellConfigurator {
    
    // MARK: - Properties
    var identifier: String { get }
    var height: CGFloat? { get }
    var width: CGFloat? { get }
    
    // MARK: - Public methods
    func configure(cell: UIView)
    func getItem() -> Any
}

final class ViewCellConfigurator<CellType: ConfigurableCellProtocol, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UIViewCellNib {
    
    // MARK: - Properties
    let identifier = CellType.identifier
    
    var item: DataType
    var height: CGFloat?
    var width: CGFloat?
    
    // MARK: - Initializators
    init(item: DataType, height: CGFloat? = nil, width: CGFloat? = nil) {
        self.item = item
        self.height = height
        self.width = width
    }
    
    // MARK: - Public methods
    func configure(cell: UIView) {
        (cell as? CellType)?.configure(data: item)
    }
    
    func getItem() -> Any {
        return item
    }
}

public protocol UIViewCellNib {
    
}

public extension UIViewCellNib {
    
    static var nibName: String {
        return String(describing: self)
    }
    
    static var identifier: String {
        return nibName + "Identifier"
    }
    
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
