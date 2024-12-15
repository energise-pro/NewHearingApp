//
//  ShowMessageViewController.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 15.12.2024.
//

import UIKit

class ShowMessageViewController: UIViewController {
    // MARK: - Private Properties
    private let messageText: String
    
    // MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Init
    init(messageText: String) {
        self.messageText = messageText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        messageLabel.text = messageText
    }
}
