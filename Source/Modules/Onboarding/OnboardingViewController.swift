//
//  OnboardingView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 20/02/2025.
//

import UIKit
import SnapKit

extension Onboarding {
    final class ViewController: UIViewController {

        private var model: ViewModel

        private let viewOnboarding: View = {
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
            viewOnboarding.configure()
        }

        private func setupConstraints() {
            view.addSubview(viewOnboarding)

            viewOnboarding.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
