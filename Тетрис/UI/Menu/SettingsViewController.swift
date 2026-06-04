import UIKit

final class SettingsViewController: UIViewController {
    private let services: AppServices

    private let themeControl = UISegmentedControl(items: ThemePreset.allCases.map(\.title))
    private let musicSwitch = UISwitch()
    private let sfxSwitch = UISwitch()
    private let hapticsSwitch = UISwitch()
    private let card = UIView()
    private let backgroundGradient = CAGradientLayer()
    private var rowLabels: [UILabel] = []
    private let contentStack = UIStackView()

    init(services: AppServices) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "settings.title".localized
        setupUI()
        load()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyNavigationAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    private func setupUI() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        themeControl.translatesAutoresizingMaskIntoConstraints = false
        themeControl.apportionsSegmentWidthsByContent = true
        themeControl.addTarget(self, action: #selector(save), for: .valueChanged)

        contentStack.addArrangedSubview(makeRow(title: "settings.theme".localized, accessory: themeControl))
        contentStack.addArrangedSubview(makeRow(title: "settings.music".localized, accessory: musicSwitch))
        contentStack.addArrangedSubview(makeRow(title: "settings.sfx".localized, accessory: sfxSwitch))
        contentStack.addArrangedSubview(makeRow(title: "settings.haptics".localized, accessory: hapticsSwitch))

        [musicSwitch, sfxSwitch, hapticsSwitch].forEach {
            $0.addTarget(self, action: #selector(save), for: .valueChanged)
        }

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        view.addSubview(card)
        card.addSubview(contentStack)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    private func makeRow(title: String, accessory: UIView) -> UIView {
        let row = UIView()
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .body)
        rowLabels.append(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        accessory.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        row.addSubview(accessory)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            accessory.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            accessory.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            label.trailingAnchor.constraint(lessThanOrEqualTo: accessory.leadingAnchor, constant: -12),
            row.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            row.topAnchor.constraint(equalTo: label.topAnchor, constant: -8)
        ])
        return row
    }

    private func load() {
        let settings = services.persistence.loadSettings()
        if let index = ThemePreset.allCases.firstIndex(of: settings.selectedTheme) {
            themeControl.selectedSegmentIndex = index
        }
        musicSwitch.isOn = settings.musicEnabled
        sfxSwitch.isOn = settings.sfxEnabled
        hapticsSwitch.isOn = settings.hapticsEnabled
    }

    @objc private func save() {
        let index = max(0, themeControl.selectedSegmentIndex)
        let theme = ThemePreset.allCases[index]
        let settings = PlayerSettings(
            selectedTheme: theme,
            musicEnabled: musicSwitch.isOn,
            sfxEnabled: sfxSwitch.isOn,
            hapticsEnabled: hapticsSwitch.isOn
        )
        services.persistence.saveSettings(settings)
        services.feedback.updateBackgroundMusic(enabled: settings.musicEnabled)
        applyTheme()
    }

    private func applyTheme() {
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        backgroundGradient.colors = [theme.background.cgColor, theme.backgroundSecondary.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0.2, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.8, y: 1)
        card.backgroundColor = theme.panel.withAlphaComponent(0.8)
        card.layer.borderColor = theme.panelStroke.cgColor
        card.layer.shadowColor = theme.shadowColor.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowRadius = 16
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        themeControl.selectedSegmentTintColor = theme.accent
        themeControl.backgroundColor = theme.backgroundSecondary.withAlphaComponent(0.75)
        themeControl.setTitleTextAttributes([
            .foregroundColor: theme.secondaryReadableText,
            .font: AppTypography.body(theme: theme, size: 13, weight: .semibold)
        ], for: .normal)
        themeControl.setTitleTextAttributes([
            .foregroundColor: theme.isRetro ? UIColor.black : UIColor.black,
            .font: AppTypography.body(theme: theme, size: 13, weight: .bold)
        ], for: .selected)
        [musicSwitch, sfxSwitch, hapticsSwitch].forEach {
            $0.onTintColor = theme.accent
        }
        rowLabels.forEach {
            $0.textColor = theme.primaryReadableText
            $0.font = AppTypography.body(theme: theme, size: 18, weight: .semibold)
        }
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
}
