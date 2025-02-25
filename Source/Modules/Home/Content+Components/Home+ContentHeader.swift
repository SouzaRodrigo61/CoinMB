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
            return view
        }()
        
        private let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
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
            label.font = .systemFont(ofSize: 24, weight: .bold)
            label.textColor = .label
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let actionButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
            button.tintColor = .label
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            return button
        }()
        
        private let searchContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemGray6
            view.layer.cornerRadius = 12
            return view
        }()
        
        private let searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Pesquisar criptomoeda"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .clear
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .clear
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
            }
        }
        
        private func setupConstraints() {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            stackView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(separatorView.snp.top).offset(-16)
            }
            
            searchContainer.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
            
            searchBar.snp.makeConstraints { make in
                make.edges.equalToSuperview()
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
