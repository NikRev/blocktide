import UIKit

final class StyledButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    private var currentTheme: AppTheme?
    private var emphasizedStyle = true

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.72
        titleLabel?.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.borderWidth = 1
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(theme: AppTheme, emphasized: Bool = true) {
        currentTheme = theme
        emphasizedStyle = emphasized
        titleLabel?.font = AppTypography.body(theme: theme, size: 15, weight: .semibold)
        setTitleColor(theme.primaryReadableText, for: .normal)
        tintColor = theme.primaryReadableText
        refreshStyle()
    }

    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? 0.97 : 1
            transform = CGAffineTransform(scaleX: scale, y: scale)
            alpha = isHighlighted ? 0.96 : 1
            layer.shadowOpacity = isHighlighted ? 0.2 : 0.35
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    private func refreshStyle() {
        guard let theme = currentTheme else { return }
        if theme.isRetro {
            layer.cornerRadius = 22
            layer.shadowRadius = 8
            layer.shadowOffset = CGSize(width: 0, height: 5)
            layer.borderColor = UIColor(red: 0.38, green: 0.25, blue: 0.07, alpha: 0.45).cgColor
        } else {
            layer.cornerRadius = 16
            layer.shadowRadius = 12
            layer.shadowOffset = CGSize(width: 0, height: 8)
        }
        if emphasizedStyle {
            gradientLayer.colors = [theme.accent.cgColor, theme.accentSecondary.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            if !theme.isRetro {
                layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
            }
            layer.shadowColor = theme.shadowColor.cgColor
        } else {
            gradientLayer.colors = [theme.panel.cgColor, theme.backgroundSecondary.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            layer.borderColor = theme.panelStroke.cgColor
            layer.shadowColor = UIColor.black.cgColor
        }
    }
}
