//
//  AppDelegate.swift
//  iOS CoinMB
//
//  Created by Rodrigo Souza on 21/02/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Removemos a propriedade 'window', pois agora ela será gerenciada pelo SceneDelegate.

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configurações globais e iniciais que não envolvam a criação da janela.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Retorna a configuração padrão para a criação de uma nova cena
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Chamado quando o usuário descarta uma sessão de cena.
    }
}
