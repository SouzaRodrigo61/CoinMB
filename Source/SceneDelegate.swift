//
//  SceneDelegate.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()

        let rootCoordinator: NavigationCoordinator = .home
        rootCoordinator.navigate(navigationController)

        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Chamado quando a cena é descartada.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Chamado quando a cena torna-se ativa.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Chamado quando a cena está prestes a se tornar inativa.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Chamado quando a cena está prestes a entrar em primeiro plano.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Chamado quando a cena entra em background.
    }
}
