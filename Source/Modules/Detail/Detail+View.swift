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

        private let tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()

        // MARK: - Initializers

        init() {
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Methods

        func configure() {
            backgroundColor = .red
        }

        private func setupTableView() {
            addSubview(tableView)

            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

//            tableView.register(Detail.Content.Cell.self, forCellReuseIdentifier: Detail.Content.Cell.identifier)   
//            tableView.dataSource = self
//            tableView.delegate = self
        }
    }
}

//extension Detail.View: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Detail.Content.Cell.identifier, for: indexPath) as! Detail.Content.Cell
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        dump("didSelectRowAt: \(indexPath.row)", name: "didSelectRowAt -> Table View")
//    }
//}
