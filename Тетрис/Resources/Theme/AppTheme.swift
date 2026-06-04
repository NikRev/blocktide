import UIKit

enum ThemePreset: String, CaseIterable, Codable {
    case neon
    case retro
    case minimalDark
    case light

    var title: String {
        switch self {
        case .neon: return "theme.neon".localized
        case .retro: return "theme.retro".localized
        case .minimalDark: return "theme.minimal_dark".localized
        case .light: return "theme.light".localized
        }
    }
}

struct AppTheme {
    let preset: ThemePreset
    let background: UIColor
    let backgroundSecondary: UIColor
    let panel: UIColor
    let panelStroke: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
    let accent: UIColor
    let accentSecondary: UIColor
    let boardBackground: UIColor
    let shadowColor: UIColor
    let ghostAlpha: CGFloat
    
    var primaryReadableText: UIColor {
        switch preset {
        case .neon, .minimalDark:
            return .white
        case .retro:
            return UIColor(red: 0.08, green: 0.11, blue: 0.08, alpha: 1)
        case .light:
            return UIColor(red: 0.08, green: 0.1, blue: 0.12, alpha: 1)
        }
    }

    var secondaryReadableText: UIColor {
        switch preset {
        case .neon, .minimalDark:
            return UIColor(white: 0.9, alpha: 1)
        case .retro:
            return UIColor(red: 0.16, green: 0.22, blue: 0.16, alpha: 1)
        case .light:
            return UIColor(red: 0.22, green: 0.27, blue: 0.31, alpha: 1)
        }
    }

    var isRetro: Bool {
        preset == .retro
    }

    func withAccent(_ accent: UIColor, secondary: UIColor) -> AppTheme {
        AppTheme(
            preset: preset,
            background: background,
            backgroundSecondary: backgroundSecondary,
            panel: panel,
            panelStroke: panelStroke,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accent: accent,
            accentSecondary: secondary,
            boardBackground: boardBackground,
            shadowColor: shadowColor,
            ghostAlpha: ghostAlpha
        )
    }

    static func from(_ preset: ThemePreset) -> AppTheme {
        switch preset {
        case .neon:
            return AppTheme(
                preset: .neon,
                background: UIColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1),
                backgroundSecondary: UIColor(red: 0.08, green: 0.12, blue: 0.21, alpha: 1),
                panel: UIColor(red: 0.11, green: 0.13, blue: 0.20, alpha: 1),
                panelStroke: UIColor(red: 0.25, green: 0.86, blue: 1.0, alpha: 0.35),
                textPrimary: .white,
                textSecondary: UIColor(white: 0.8, alpha: 1),
                accent: UIColor(red: 0.25, green: 0.86, blue: 1.0, alpha: 1),
                accentSecondary: UIColor(red: 0.18, green: 0.52, blue: 1, alpha: 1),
                boardBackground: UIColor(red: 0.07, green: 0.09, blue: 0.16, alpha: 1),
                shadowColor: UIColor(red: 0.07, green: 0.25, blue: 0.53, alpha: 1),
                ghostAlpha: 0.28
            )
        case .retro:
            return AppTheme(
                preset: .retro,
                background: UIColor(red: 0.63, green: 0.69, blue: 0.63, alpha: 1),
                backgroundSecondary: UIColor(red: 0.56, green: 0.63, blue: 0.58, alpha: 1),
                panel: UIColor(red: 0.74, green: 0.8, blue: 0.74, alpha: 1),
                panelStroke: UIColor(red: 0.35, green: 0.42, blue: 0.35, alpha: 0.55),
                textPrimary: UIColor(red: 0.1, green: 0.15, blue: 0.1, alpha: 1),
                textSecondary: UIColor(red: 0.18, green: 0.24, blue: 0.18, alpha: 1),
                accent: UIColor(red: 0.99, green: 0.78, blue: 0.16, alpha: 1),
                accentSecondary: UIColor(red: 0.94, green: 0.6, blue: 0.05, alpha: 1),
                boardBackground: UIColor(red: 0.72, green: 0.78, blue: 0.73, alpha: 1),
                shadowColor: UIColor(red: 0.31, green: 0.36, blue: 0.31, alpha: 1),
                ghostAlpha: 0.2
            )
        case .minimalDark:
            return AppTheme(
                preset: .minimalDark,
                background: UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1),
                backgroundSecondary: UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1),
                panel: UIColor(red: 0.13, green: 0.13, blue: 0.16, alpha: 1),
                panelStroke: UIColor(white: 1, alpha: 0.16),
                textPrimary: .white,
                textSecondary: UIColor(white: 0.72, alpha: 1),
                accent: UIColor(red: 0.44, green: 0.84, blue: 0.5, alpha: 1),
                accentSecondary: UIColor(red: 0.25, green: 0.55, blue: 0.3, alpha: 1),
                boardBackground: UIColor(red: 0.11, green: 0.11, blue: 0.15, alpha: 1),
                shadowColor: UIColor(white: 0, alpha: 1),
                ghostAlpha: 0.2
            )
        case .light:
            return AppTheme(
                preset: .light,
                background: UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1),
                backgroundSecondary: UIColor(red: 0.86, green: 0.91, blue: 0.97, alpha: 1),
                panel: UIColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1),
                panelStroke: UIColor(red: 0.62, green: 0.72, blue: 0.86, alpha: 0.45),
                textPrimary: UIColor(red: 0.08, green: 0.1, blue: 0.12, alpha: 1),
                textSecondary: UIColor(red: 0.22, green: 0.27, blue: 0.31, alpha: 1),
                accent: UIColor(red: 0.17, green: 0.56, blue: 1.0, alpha: 1),
                accentSecondary: UIColor(red: 0.14, green: 0.42, blue: 0.9, alpha: 1),
                boardBackground: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1),
                shadowColor: UIColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 1),
                ghostAlpha: 0.24
            )
        }
    }
}

private extension UIColor {
    var isDarkColor: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return true }
        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)
        return luminance < 0.5
    }
}

enum TetrominoPalette {
    static func color(for type: TetrominoType, theme: AppTheme) -> UIColor {
        if theme.isRetro {
            return UIColor(red: 0.13, green: 0.17, blue: 0.13, alpha: 1)
        }
        switch type {
        case .i: return UIColor(red: 0.2, green: 0.86, blue: 0.96, alpha: 1)
        case .o: return UIColor(red: 0.99, green: 0.87, blue: 0.19, alpha: 1)
        case .t: return UIColor(red: 0.66, green: 0.39, blue: 0.92, alpha: 1)
        case .s: return UIColor(red: 0.36, green: 0.87, blue: 0.38, alpha: 1)
        case .z: return UIColor(red: 0.93, green: 0.28, blue: 0.35, alpha: 1)
        case .j: return UIColor(red: 0.3, green: 0.47, blue: 0.95, alpha: 1)
        case .l: return UIColor(red: 0.96, green: 0.6, blue: 0.24, alpha: 1)
        }
    }
}
