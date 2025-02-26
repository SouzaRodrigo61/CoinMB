//
//  DetailView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit
import SnapKit

extension Detail {
    final class ViewController: UIViewController {

        private var viewModel: ViewModel

        private let screen: View = {
            let view = View()
            return view
        }()

        init(model: ViewModel) {
            self.viewModel = model
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // reapresenta o navigation bar
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            setupConstraints()

            // MARK: Configure
        }

        private func setupConstraints() {
            view.addSubview(screen)

            screen.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        private func setupSink() { 
            viewModel.$rate
                .receive(on: DispatchQueue.main)
                .sink { [weak self] model in
                    guard let self else { return }
                    screen.configure(with: model)
                }
                .store(in: &viewModel.cancellables)
        }
    }
}
