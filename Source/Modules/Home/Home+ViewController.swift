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
            view.backgroundColor = .systemBackground

            screen.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            screen.onTimeFilterSelected = { [weak self] filter in
                self?.viewModel.updateTimeFilter(filter)
            }
            
            screen.onContentTapped = { [weak self] model in 
                guard let self else { return }
                guard let navigationController else { return }
                
                let detail = NavigationCoordinator.coordinatorDetail(with: model)
                
                detail.navigate(navigationController)
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
            
            viewModel.$currentRateError
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    guard let self, let error = error else { return }
                    self.handleCurrentRateError(error)
                }
                .store(in: &viewModel.cancellables)
            
            viewModel.$exchangePeriodError
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    guard let self, let error = error else { return }
                    self.handleExchangePeriodError(error)
                }
                .store(in: &viewModel.cancellables)
            
            viewModel.$exchangeIconError
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    guard let self, let error = error else { return }
                    self.handleExchangeIconError(error)
                }
                .store(in: &viewModel.cancellables)
        }

        private func handleCurrentRateError(_ error: Repository.NetworkError) {
            let title = "Erro na Taxa Atual"
            let message: String
            
            switch error {
            case .decode(msg: let msg, error: let error):
                message = msg
            case .network(let error):
                message = error.localizedDescription
            }
            
            showErrorAlert(title: title, message: message)
        }
        
        private func handleExchangePeriodError(_ error: Repository.NetworkError) {
            let title = "Erro no Histórico"
            let message: String
            
            switch error {
            case .decode(msg: let msg, error: let error):
                message = msg
            case .network(let error):
                message = error.localizedDescription
            }
            
            showErrorAlert(title: title, message: message)
        }
        
        private func handleExchangeIconError(_ error: Repository.NetworkError) {
            let title = "Erro nos Ícones"
            let message: String
            
            switch error {
            case .decode(msg: let msg, error: let error):
                message = msg
            case .network(let error):
                message = error.localizedDescription
            }
            
            // Para erros de ícone, podemos apenas logar, já que não é crítico
            print("Erro de ícone: \(message)")
        }
        
        private func showErrorAlert(title: String, message: String) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))
            
            alert.addAction(UIAlertAction(
                title: "Tentar Novamente",
                style: .default,
                handler: { [weak self] _ in
                    self?.viewModel.fetchCurrentRates()
                }
            ))
            
            present(alert, animated: true)
        }

        private func viewModelDidInitialize() {
            self.viewModel.fetchCurrentRates()
        }
    }
}
