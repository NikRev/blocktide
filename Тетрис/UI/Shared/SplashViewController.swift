import UIKit

final class SplashViewController: UIViewController {
    private let theme: AppTheme
    private let completion: () -> Void
    private let backgroundGradient = CAGradientLayer()
    private let logoCard = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(theme: AppTheme, completion: @escaping () -> Void) {
        self.theme = theme
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(backgroundGradient, at: 0)
        backgroundGradient.colors = [theme.background.cgColor, theme.backgroundSecondary.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0.15, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.85, y: 1)

        logoCard.translatesAutoresizingMaskIntoConstraints = false
        logoCard.layer.cornerRadius = 28
        logoCard.layer.cornerCurve = .continuous
        logoCard.backgroundColor = theme.panel.withAlphaComponent(0.9)
        logoCard.layer.borderWidth = 1
        logoCard.layer.borderColor = theme.panelStroke.cgColor
        logoCard.layer.shadowColor = theme.shadowColor.cgColor
        logoCard.layer.shadowOpacity = 0.35
        logoCard.layer.shadowRadius = 24
        logoCard.layer.shadowOffset = CGSize(width: 0, height: 10)

        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.text = "app.name.upper".localized
        logoLabel.textColor = theme.primaryReadableText
        logoLabel.font = AppTypography.display(theme: theme, size: 34)
        logoLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "splash.subtitle".localized
        subtitleLabel.textColor = theme.secondaryReadableText
        subtitleLabel.font = AppTypography.body(theme: theme, size: 15, weight: .medium)
        subtitleLabel.textAlignment = .center

        view.addSubview(logoCard)
        logoCard.addSubview(logoLabel)
        logoCard.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            logoCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            logoCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),

            logoLabel.topAnchor.constraint(equalTo: logoCard.topAnchor, constant: 32),
            logoLabel.leadingAnchor.constraint(equalTo: logoCard.leadingAnchor, constant: 16),
            logoLabel.trailingAnchor.constraint(equalTo: logoCard.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: logoLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: logoCard.bottomAnchor, constant: -28)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAndFinish()
    }

    private func animateAndFinish() {
        logoCard.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        logoCard.alpha = 0
        UIView.animate(withDuration: 0.55, delay: 0, options: [.curveEaseOut]) {
            self.logoCard.alpha = 1
            self.logoCard.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.completion()
            }
        }
    }
}
