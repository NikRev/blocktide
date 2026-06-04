import UIKit

final class HomeViewController: UIViewController {
    private let services: AppServices
    private let onStartGame: (GameMode) -> Void
    private let onOpenSettings: () -> Void

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()
    private let heroCard = UIView()
    private let statsCard = UIView()
    private let settingsButton = StyledButton(title: "home.settings".localized)
    private let statsLabel = UILabel()
    private let backgroundGradient = CAGradientLayer()

    init(
        services: AppServices,
        onStartGame: @escaping (GameMode) -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.services = services
        self.onStartGame = onStartGame
        self.onOpenSettings = onOpenSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        refreshStats()
        showOnboardingIfNeeded()
        services.gameCenter.authenticateIfNeeded(presenter: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        refreshStats()
        applyNavigationAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    private func setupUI() {
        title = "app.name".localized
        view.layer.insertSublayer(backgroundGradient, at: 0)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "app.name.upper".localized

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "home.subtitle".localized
        subtitleLabel.numberOfLines = 0

        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.layer.cornerRadius = 24
        heroCard.layer.cornerCurve = .continuous
        heroCard.layer.borderWidth = 1

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        GameMode.allCases.forEach { mode in
            let button = StyledButton(title: "\(mode.title)\n\(mode.subtitle)")
            button.tag = modeTag(mode)
            button.addTarget(self, action: #selector(didTapMode(_:)), for: .touchUpInside)
            button.titleLabel?.numberOfLines = 0
            button.contentHorizontalAlignment = .left
            button.setImage(modeIcon(mode), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.semanticContentAttribute = .forceLeftToRight
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 8)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            stack.addArrangedSubview(button)
        }

        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        settingsButton.contentHorizontalAlignment = .left
        settingsButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 10)
        settingsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        statsCard.translatesAutoresizingMaskIntoConstraints = false
        statsCard.layer.cornerRadius = 18
        statsCard.layer.cornerCurve = .continuous
        statsCard.layer.borderWidth = 1

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        statsLabel.numberOfLines = 0

        heroCard.addSubview(titleLabel)
        heroCard.addSubview(subtitleLabel)
        heroCard.addSubview(stack)
        heroCard.addSubview(settingsButton)
        statsCard.addSubview(statsLabel)
        view.addSubview(heroCard)
        view.addSubview(statsCard)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            heroCard.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            heroCard.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),

            settingsButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16),
            settingsButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -18),

            statsCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 12),
            statsCard.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor),

            statsLabel.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 14),
            statsLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            statsLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),
            statsLabel.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -14)
        ])
    }

    private func modeTag(_ mode: GameMode) -> Int {
        switch mode {
        case .classic: return 101
        case .sprint: return 102
        case .endless: return 103
        }
    }

    private func modeFrom(tag: Int) -> GameMode {
        switch tag {
        case 101: return .classic
        case 102: return .sprint
        default: return .endless
        }
    }

    @objc private func didTapMode(_ sender: UIButton) {
        let mode = modeFrom(tag: sender.tag)
        onStartGame(mode)
    }

    @objc private func didTapSettings() {
        onOpenSettings()
    }

    private func applyTheme() {
        let settings = services.persistence.loadSettings()
        let theme = AppTheme.from(settings.selectedTheme)
        titleLabel.font = AppTypography.display(theme: theme, size: 44)
        subtitleLabel.font = AppTypography.body(theme: theme, size: 15, weight: .medium)
        statsLabel.font = AppTypography.body(theme: theme, size: 14, weight: .medium)
        backgroundGradient.colors = [theme.background.cgColor, theme.backgroundSecondary.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0.15, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.85, y: 1)
        titleLabel.textColor = theme.primaryReadableText
        subtitleLabel.textColor = theme.secondaryReadableText
        statsLabel.textColor = theme.secondaryReadableText
        heroCard.backgroundColor = theme.panel.withAlphaComponent(0.82)
        heroCard.layer.borderColor = theme.panelStroke.cgColor
        heroCard.layer.shadowColor = theme.shadowColor.cgColor
        heroCard.layer.shadowOpacity = 0.3
        heroCard.layer.shadowRadius = 18
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        statsCard.backgroundColor = theme.panel.withAlphaComponent(0.75)
        statsCard.layer.borderColor = theme.panelStroke.cgColor
        stack.arrangedSubviews.compactMap { $0 as? StyledButton }.forEach { button in
            button.apply(theme: theme)
        }
        settingsButton.apply(theme: theme, emphasized: false)
    }

    private func applyNavigationAppearance() {
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = theme.primaryReadableText
    }

    private func refreshStats() {
        let stats = services.persistence.loadStats()
        let avg = stats.totalSessions == 0 ? 0 : Int(stats.totalPlayTime / Double(stats.totalSessions))
        statsLabel.text = String(
            format: "home.stats.format".localized,
            locale: Locale.current,
            stats.totalSessions,
            stats.totalLines,
            avg
        )
    }

    private func modeIcon(_ mode: GameMode) -> UIImage? {
        let name: String
        switch mode {
        case .classic:
            name = "square.stack.3d.up.fill"
        case .sprint:
            name = "bolt.fill"
        case .endless:
            name = "infinity"
        }
        return UIImage(systemName: name)
    }

    private func showOnboardingIfNeeded() {
        guard services.persistence.shouldShowOnboarding() else { return }
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let onboarding = OnboardingViewController(theme: theme) { [weak self] in
            self?.services.persistence.completeOnboarding()
        }
        present(onboarding, animated: true)
    }
}
