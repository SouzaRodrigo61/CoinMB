//
//  Home+ContentCell.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 23/02/25.
//

import UIKit

extension Home { 
    class ContentCell: UICollectionViewCell { 
        static let reuseIdentifier = "Home.ContentCell"
        
        // MARK: - UI Components
        
        
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        private func setupView() { 
            
        }
        
        // MARK: - Configuration
        
        func configure() { 
            
        }
    }
}