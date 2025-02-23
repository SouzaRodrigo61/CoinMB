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

        private var viewModel: ViewModel

        private let screen: View = {
            let view = View()
            return view
        }()

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: true)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            setupConstraints()

            // MARK: Configure
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
            viewModel.$model
                .receive(on: DispatchQueue.main)
                .sink { [weak self] model in
                    guard let self, let model = model else { return }
                    screen.configure(with: model)
                }
                .store(in: &viewModel.cancellables)
            
            viewModel.$icons
                .receive(on: DispatchQueue.main)
                .sink { [weak self] icon in 
//                    guard let self else { return }
//                    dump(icon, name: "$icons")
                }
                .store(in: &viewModel.cancellables)
        }

        private func viewModelDidInitialize() {
            DispatchQueue.global(qos: .background).async {
                self.viewModel.fetchCurrentRates()
            }
        }
    }
}
