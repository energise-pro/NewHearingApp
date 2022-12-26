//
//  PresentableView.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import UIKit

protocol PresentableView: AnyObject {
    
    var presentableViewController: UIViewController { get }
    
    func showAlert(title: String, message: String, defaultActionTitle: String, destructiveActionTitle: String?)
    func startLoading()
    func stopLoading()
}

extension PresentableView where Self: UIViewController {
    
    var presentableViewController: UIViewController {
        return self
    }
    
    func showAlert(title: String, message: String, defaultActionTitle: String, destructiveActionTitle: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: defaultActionTitle, style: .default)
        alert.addAction(defaultAction)
        if let destructiveActionTitle = destructiveActionTitle {
            let destructiveAction = UIAlertAction(title: destructiveActionTitle, style: .destructive)
            alert.addAction(destructiveAction)
        }
        present(alert, animated: true)
    }
    
    func startLoading() {
        let backgroundView = UIView(frame: view.frame)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.tag = 767676
        view.addSubview(backgroundView)
        let activityIndicator = UIActivityIndicatorView(frame: backgroundView.frame)
        activityIndicator.color = .white
        backgroundView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        let backgroundView = view.viewWithTag(767676)
        let activityIndicator = backgroundView?.subviews.first as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        backgroundView?.removeFromSuperview()
    }
}
