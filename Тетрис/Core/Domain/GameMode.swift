import Foundation

enum GameMode: String, CaseIterable, Codable {
    case classic
    case sprint
    case endless

    var title: String {
        switch self {
        case .classic: return "game_mode.classic.title".localized
        case .sprint: return "game_mode.sprint.title".localized
        case .endless: return "game_mode.endless.title".localized
        }
    }

    var subtitle: String {
        switch self {
        case .classic: return "game_mode.classic.subtitle".localized
        case .sprint: return "game_mode.sprint.subtitle".localized
        case .endless: return "game_mode.endless.subtitle".localized
        }
    }
}

struct GameModeRules {
    let initialDropInterval: TimeInterval
    let levelStepLines: Int
    let sprintTargetLines: Int?
    let allowsLeveling: Bool
    let minimumDropInterval: TimeInterval

    static func forMode(_ mode: GameMode) -> GameModeRules {
        switch mode {
        case .classic:
            return GameModeRules(
                initialDropInterval: 0.85,
                levelStepLines: 10,
                sprintTargetLines: nil,
                allowsLeveling: true,
                minimumDropInterval: 0.12
            )
        case .sprint:
            return GameModeRules(
                initialDropInterval: 0.55,
                levelStepLines: 20,
                sprintTargetLines: 40,
                allowsLeveling: false,
                minimumDropInterval: 0.3
            )
        case .endless:
            return GameModeRules(
                initialDropInterval: 0.7,
                levelStepLines: 15,
                sprintTargetLines: nil,
                allowsLeveling: true,
                minimumDropInterval: 0.09
            )
        }
    }
}

struct GameResult: Codable {
    let mode: GameMode
    let score: Int
    let lines: Int
    let level: Int
    let duration: TimeInterval
    let createdAt: Date
    let didWinSprint: Bool
}
