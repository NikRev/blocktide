import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let services: AppServices
    private lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()

    init(window: UIWindow) {
        self.window = window
        self.services = AppServices()
    }

    func start() {
        configureNavigationAppearance()
        let home = HomeViewController(
            services: services,
            onStartGame: { [weak self] mode in
                self?.showGame(mode: mode)
            },
            onOpenSettings: { [weak self] in
                self?.showSettings()
            }
        )
        navigationController.viewControllers = [home]
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let splash = SplashViewController(theme: theme) { [weak self] in
            guard let self else { return }
            UIView.transition(with: self.window, duration: 0.35, options: [.transitionCrossDissolve]) {
                self.window.rootViewController = self.navigationController
            }
        }
        window.rootViewController = splash
        window.makeKeyAndVisible()
    }

    private func configureNavigationAppearance() {
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = theme.primaryReadableText
    }

    private func showGame(mode: GameMode) {
        let game = GameViewController(
            mode: mode,
            services: services
        )
        navigationController.pushViewController(game, animated: true)
    }

    private func showSettings() {
        let settings = SettingsViewController(services: services)
        navigationController.pushViewController(settings, animated: true)
    }
}
