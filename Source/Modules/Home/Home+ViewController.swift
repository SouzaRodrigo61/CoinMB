//
//  HomeView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit
import SnapKit

extension Home {
    final class ViewController: UIViewController {

        private var model: ViewModel

        private let screen: View = {
            let view = View()
            return view
        }()

        init(model: ViewModel) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            setupConstraints()

            // MARK: Configure
            screen.configure()
            bindViewModel()
            viewModelDidInitialize()
        }

        private func setupConstraints() {
            view.addSubview(screen)

            screen.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        private func bindViewModel() {
            model.$currentRates
                .receive(on: DispatchQueue.main)
                .sink { [weak self] currentRates in
                    guard let self else { return }
                    dump(currentRates, name: "$currentRates")
                }
                .store(in: &model.cancellables)
            
            model.$icons
                .receive(on: DispatchQueue.main)
                .sink { [weak self] icon in 
                    guard let self else { return }
                    dump(icon, name: "$icons")
                }
                .store(in: &model.cancellables)
        }

        private func viewModelDidInitialize() {
            model.fetchCurrentRates(with: "BTC")
        }
    }
}
