import ProjectDescription

let project = Project(
    name: "CoinMB",
    options: .options(
        defaultKnownRegions: [
            "pt-BR",
            "en"
        ],
        developmentRegion: "pt-BR"
    ),
    packages: [
        .remote(url: "https://github.com/SimplyDanny/SwiftLintPlugins", requirement: .upToNextMajor(from: "0.57.0")),
    ], 
    settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "./xcconfigs/CoinMB-Project.xcconfig"),
        .release(name: "Release", xcconfig: "./xcconfigs/CoinMB-Project.xcconfig"),
    ]),
    targets: [
        .target(
            name: "CoinMB",
            destinations: .iOS,
            product: .app,
            bundleId: "org.coinmb.application",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ]
                ]
            ),
            sources: ["Source/**"],
            resources: [
                "Source/Resources/**",
            ],
            dependencies: [
                .external(name: "SnapKit"),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            ],
            settings: .settings(configurations: [
                .debug(name: "Debug", xcconfig: "./xcconfigs/CoinMB.xcconfig"),
                .release(name: "Release", xcconfig: "./xcconfigs/CoinMB.xcconfig"),
            ])
        ),
        .target(
            name: "SourceTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "org.coinmb.application.unitTest",
            sources: ["SourceTests/**"],
            dependencies: [
                .target(name: "CoinMB"),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            ]
        ),
        .target(
            name: "SourceUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "org.coinmb.application.uiTests",
            sources: ["SourceUITests/**"],
            dependencies: [
                .target(name: "CoinMB"),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            ]
        )
    ]
)
