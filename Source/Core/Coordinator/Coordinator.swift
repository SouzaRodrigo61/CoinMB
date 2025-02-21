//
//  Coordinator.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 22/11/24.
//

import UIKit

// Protocol Witness (Protocol Witnesses)[https://www.pointfree.co/collections/protocol-witnesses]
// Witness para definir navegação

// MARK: - Coordinating

struct Coordinating<A> {
    let navigate: (A) -> Void
}

// Define um typealias para facilitar o uso do Coordinating com UINavigationController
typealias NavigationCoordinator = Coordinating<UINavigationController>
