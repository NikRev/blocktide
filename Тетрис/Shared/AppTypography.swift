import UIKit

enum AppTypography {
    static func display(theme: AppTheme, size: CGFloat) -> UIFont {
        if theme.isRetro {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .heavy)
        }
        return UIFont.systemFont(ofSize: size, weight: .heavy)
    }

    static func title(theme: AppTheme, size: CGFloat) -> UIFont {
        if theme.isRetro {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .bold)
        }
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func body(theme: AppTheme, size: CGFloat, weight: UIFont.Weight = .medium) -> UIFont {
        if theme.isRetro {
            return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
        }
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
