//
//  DetailView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit
import SnapKit

extension Detail {
    final class View: UIView {

        // MARK: - Properties

        private lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.backgroundColor = .systemBackground
            
            tableView.register(Detail.ContentCell.self, forCellReuseIdentifier: Detail.ContentCell.identifier)   
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()

        // MARK: - Initializers
        
        private var viewModel: Home.Repository.CurrentRates.Rate?

        init() {
            super.init(frame: .zero)
            setupTableView()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Methods

        private func setupTableView() {
            addSubview(tableView)

            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension Detail.View: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Detail.ContentCell.identifier, for: indexPath) as? Detail.ContentCell else {
            return UITableViewCell()
        }
        
        guard let viewModel else { return UITableViewCell() }
        cell.configure(with: viewModel)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Detail.View { 
    func configure(with model: Home.Repository.CurrentRates.Rate) {
        self.viewModel = model
        
        self.tableView.reloadData()
    }
}
