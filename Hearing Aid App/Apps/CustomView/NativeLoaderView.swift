import UIKit

final class NativeLoaderView: UIView {
    
    private struct Defaults {
        static let sideValue: CGFloat = 100.0
    }
    
    // MARK: - Properties
    private var activityView = UIActivityIndicatorView()
    
    // MARK: - Initializators
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAnimationView()
    }
    
    required init() {
        super.init(frame: CGRect(x: .zero, y: .zero, width: Defaults.sideValue, height: Defaults.sideValue))
        configureAnimationView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAnimationView()
    }
    
    // MARK: - Internal methods
    static func showLoader(at view: UIView, animated: Bool) {
        hideLoader(for: view, animated: false)
        
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        backgroundView.layer.name = "BigBackgroundViewLayer"
        
        let loaderView = self.init()
        loaderView.startAnimating()
        
        backgroundView.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        
        view.addSubview(backgroundView)
        view.addBaseConstraintsFor(view: backgroundView)
    }
    
    static func showBackground(at view: UIView, animated: Bool) {
        hideLoader(for: view, animated: false)
        
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        backgroundView.layer.name = "BigBackgroundViewLayer"
        
        view.addSubview(backgroundView)
        view.addBaseConstraintsFor(view: backgroundView)
    }
    
    static func hideLoader(for view: UIView, animated: Bool) {
        view.subviews.reversed()
            .first(where: { $0.layer.name == "BigBackgroundViewLayer" })?
            .removeFromSuperview()
    }
    
    static func hideBackground(for view: UIView, animated: Bool) {
        view.subviews.reversed()
            .first(where: { $0.layer.name == "BigBackgroundViewLayer" })?
            .removeFromSuperview()
    }
    
    // MARK - Private methods
    private func configureAnimationView() {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        
        activityView = activityIndicatorView
        
        addSubview(activityIndicatorView)
        addBaseConstraintsFor(view: activityIndicatorView)
        
        heightAnchor.constraint(equalToConstant: frame.width).isActive = true
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
    }
    
    private func startAnimating() {
        activityView.startAnimating()
    }
    
    private func stopAnimating() {
        activityView.stopAnimating()
    }
}

extension UIView {
    
    @available(iOS 9, *)
    @discardableResult
    public func addBaseConstraintsFor(view: UIView, layoutGuide: UILayoutGuide? = nil, edgeInsets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
    
        var constraints: [NSLayoutConstraint] = []
        let topAnchor = layoutGuide?.topAnchor ?? self.topAnchor
        let bottomAnchor = layoutGuide?.bottomAnchor ?? self.bottomAnchor
        constraints.append(view.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top))
        constraints.append(view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: edgeInsets.bottom))
        let leftAnchor = layoutGuide?.leftAnchor ?? self.leftAnchor
        let rightAnchor = layoutGuide?.rightAnchor ?? self.rightAnchor
        constraints.append(view.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeInsets.left))
        constraints.append(view.rightAnchor.constraint(equalTo: rightAnchor, constant: edgeInsets.right))
        constraints.forEach { $0.isActive = true }
        
        return constraints
    }
}
