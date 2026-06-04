import UIKit

final class OnboardingViewController: UIViewController {
    private let theme: AppTheme
    private let onStart: () -> Void
    private let dimView = UIView()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let startButton = StyledButton(title: "onboarding.start".localized)

    init(theme: AppTheme, onStart: @escaping () -> Void) {
        self.theme = theme
        self.onStart = onStart
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
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.52)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 22
        card.layer.cornerCurve = .continuous
        card.backgroundColor = theme.panel
        card.layer.borderWidth = 1
        card.layer.borderColor = theme.panelStroke.cgColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "onboarding.title".localized
        titleLabel.textColor = theme.primaryReadableText
        titleLabel.font = AppTypography.title(theme: theme, size: 28)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = theme.secondaryReadableText
        messageLabel.numberOfLines = 0
        messageLabel.font = AppTypography.body(theme: theme, size: 16, weight: .medium)
        messageLabel.text = "onboarding.message".localized

        startButton.apply(theme: theme)
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)

        view.addSubview(dimView)
        view.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(messageLabel)
        card.addSubview(startButton)

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

            startButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 18),
            startButton.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            startButton.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
            startButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func didTapStart() {
        dismiss(animated: true) { [onStart] in
            onStart()
        }
    }
}
