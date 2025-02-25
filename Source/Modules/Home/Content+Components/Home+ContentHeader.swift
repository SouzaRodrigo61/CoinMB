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
        
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.05
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 8
            return view
        }()
        
        private let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            return stack
        }()
        
        private let headerStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.alignment = .center
            stack.distribution = .equalSpacing
            return stack
        }()
        
        private let titleStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            return stack
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 28, weight: .heavy)
            label.textColor = .label
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = .secondaryLabel
            label.numberOfLines = 2
            return label
        }()
        
        private let actionButton: UIButton = {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            let image = UIImage(systemName: "slider.horizontal.3", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .systemIndigo
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 20
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            return button
        }()
        
        private let searchContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemGray6
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
            return view
        }()
        
        private let searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Pesquisar criptomoeda"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .clear
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .clear
            
            searchBar.searchTextField.font = .systemFont(ofSize: 16, weight: .regular)
            
            let searchIconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let searchIcon = UIImage(systemName: "magnifyingglass", withConfiguration: searchIconConfig)
            searchBar.setImage(searchIcon, for: .search, state: .normal)
            
            return searchBar
        }()
        
        private let separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .separator.withAlphaComponent(0.5)
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
            
            addSubview(containerView)
            containerView.addSubview(stackView)
            
            stackView.addArrangedSubview(headerStackView)
            stackView.addArrangedSubview(searchContainer)
            
            headerStackView.addArrangedSubview(titleStackView)
            headerStackView.addArrangedSubview(actionButton)
            
            titleStackView.addArrangedSubview(titleLabel)
            titleStackView.addArrangedSubview(subtitleLabel)
            
            searchContainer.addSubview(searchBar)
            addSubview(separatorView)
            
            searchBar.delegate = self
            setupConstraints()
            setupSearchBar()
        }
        
        private func setupSearchBar() {
            searchBar.showsCancelButton = true
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.setTitle("Cancelar", for: .normal)
                cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
                cancelButton.tintColor = .systemIndigo
            }
            
            searchBar.searchTextField.tintColor = .systemIndigo
            searchBar.searchTextField.textColor = .label
        }
        
        private func setupConstraints() {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            stackView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(24)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalTo(separatorView.snp.top).offset(-20)
            }
            
            searchContainer.snp.makeConstraints { make in
                make.height.equalTo(52)
            }
            
            searchBar.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
            }
            
            separatorView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(0.5)
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
