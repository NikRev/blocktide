import UIKit

final class GameResultViewController: UIViewController {
    private let result: GameResult
    private let theme: AppTheme
    private let onReplay: () -> Void
    private let onBack: () -> Void

    private let dimView = UIView()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let replayButton = StyledButton(title: "result.replay".localized)
    private let backButton = StyledButton(title: "result.back".localized)

    init(result: GameResult, theme: AppTheme, onReplay: @escaping () -> Void, onBack: @escaping () -> Void) {
        self.result = result
        self.theme = theme
        self.onReplay = onReplay
        self.onBack = onBack
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.55)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        card.backgroundColor = theme.panel
        card.layer.borderWidth = 1
        card.layer.borderColor = theme.panelStroke.cgColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppTypography.title(theme: theme, size: 30)
        titleLabel.textColor = theme.primaryReadableText
        titleLabel.text = result.didWinSprint ? "result.sprint_complete".localized : "result.game_over".localized

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = theme.secondaryReadableText
        messageLabel.font = AppTypography.body(theme: theme, size: 17, weight: .medium)
        messageLabel.numberOfLines = 0
        messageLabel.text = String(
            format: "result.stats.format".localized,
            locale: Locale.current,
            result.score,
            result.lines,
            result.level
        )

        replayButton.apply(theme: theme)
        replayButton.addTarget(self, action: #selector(didTapReplay), for: .touchUpInside)
        backButton.apply(theme: theme, emphasized: false)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        view.addSubview(dimView)
        view.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(messageLabel)
        card.addSubview(replayButton)
        card.addSubview(backButton)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            replayButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            replayButton.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            replayButton.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
            replayButton.heightAnchor.constraint(equalToConstant: 52),

            backButton.topAnchor.constraint(equalTo: replayButton.bottomAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: replayButton.leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: replayButton.trailingAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 52),
            backButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
    }

    @objc private func didTapReplay() {
        dismiss(animated: true) { [onReplay] in
            onReplay()
        }
    }

    @objc private func didTapBack() {
        dismiss(animated: true) { [onBack] in
            onBack()
        }
    }
}
