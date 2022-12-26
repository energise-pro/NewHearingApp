//
//  LanguagesListViewController.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 21.12.2022.
//

import UIKit

final class LanguagesListViewController: UIViewController {

    // MARK: - Private Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emptyStateLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    private var presenter: LanguagesListPresenterProtocol!
    
    // MARK: - Object Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private Methods
    @IBAction private func didTapCloseButton() {
        presenter.didTapCloseButton()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LanguageTableViewCell.self)
    }
}

// MARK: - UITableViewDataSource
extension LanguagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageTableViewCell.identifier) as! LanguageTableViewCell
        presenter.configure(cell: cell, forRowAt: indexPath.row)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LanguagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRow(at: indexPath.row)
    }
}

// MARK: - LanguagesListView
extension LanguagesListViewController: LanguagesListView {
    
    func setPresenter(_ presenter: LanguagesListPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configureUI() {
        configureTableView()
    }
    
    func configureLocalization() {
        titleLabel.text = presenter.title
    }
}
