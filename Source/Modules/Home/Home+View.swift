//
//  HomeView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit

extension Home {
    final class View: UIView {

        init() {
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure() {
            backgroundColor = .red
        }
    }
}
