//
//  Home+ContentHeader.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit
import SnapKit

extension Home { 
    final class ContentHeader: UICollectionReusableView { 
        static let reuseIdentifier = "Home.ContentHeader"
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .bold)
            label.textColor = .label
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let actionButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            button.tintColor = .label
            return button
        }()
        
        private let searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Pesquisar criptomoeda"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .systemBackground
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .systemGray6
            return searchBar
        }()
        
        private let separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            return view
        }()
        
        var onSearchTextChanged: ((String) -> Void)?
        
        private var searchWorkItem: DispatchWorkItem?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .systemBackground
            
            addSubview(titleLabel)
            addSubview(subtitleLabel)
            addSubview(actionButton)
            addSubview(searchBar)
            addSubview(separatorView)
            
            searchBar.delegate = self
            setupConstraints()
            setupSearchBar()
        }
        
        private func setupSearchBar() {
            searchBar.showsCancelButton = true
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.setTitle("Cancelar", for: .normal)
            }
        }
        
        private func setupConstraints() {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(16)
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.leading.equalTo(titleLabel)
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
            }
            
            searchBar.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(8)
                make.trailing.equalToSuperview().offset(-8)
                make.height.equalTo(44)
            }
            
            separatorView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
            
            actionButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(16)
            }
        }
        
        func configure(title: String, subtitle: String) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle.isEmpty
        }
    }
}

extension Home.ContentHeader: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.onSearchTextChanged?(searchText)
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        onSearchTextChanged?("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
