//
//  SearchOverlayViewController.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 25/02/25.
//

import UIKit
import SnapKit

extension Home { 
    class SearchOverlayViewController: UIViewController {
        var sourceButton: UIButton?
        var sourceButtonFrame: CGRect = .zero
        
        private lazy var searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Iniciar busca"
            searchBar.searchBarStyle = .minimal
            searchBar.alpha = 0
            return searchBar
        }()
        
        private lazy var overlayView: UIView = {
            let view = UIView()
            return view
        }()
        
        private lazy var searchContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 24
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            return view
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupViews()
        }
        
        private func setupViews() {
            view.backgroundColor = .systemBackground
            
            view.addSubview(overlayView)
            view.addSubview(searchContainer)
            searchContainer.addSubview(searchBar)
            
            overlayView.frame = view.bounds
            searchContainer.frame = sourceButtonFrame
            
            searchBar.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
            }
        }
        
        func animateAppearance() {
            let finalFrame = CGRect(x: 16, y: 60, width: view.bounds.width - 32, height: 48)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.searchContainer.frame = finalFrame
                self.overlayView.backgroundColor = .systemGray
                self.searchBar.alpha = 1
            } completion: { _ in
                self.searchBar.becomeFirstResponder()
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: view)
            
            if !searchContainer.frame.contains(location) {
                dismissWithAnimation()
            }
        }
        
        private func dismissWithAnimation() {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.searchContainer.frame = self.sourceButtonFrame
                self.overlayView.backgroundColor = .clear
                self.searchBar.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        }
    }
}
