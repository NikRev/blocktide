import Foundation
import GameKit
import UIKit

final class GameCenterService {
    private(set) var isAuthenticated = false

    func authenticateIfNeeded(presenter: UIViewController? = nil) {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController, let presenter {
                presenter.present(viewController, animated: true)
            } else if let viewController {
                UIApplication.shared.connectedScenes
                    .compactMap { scene in
                        (scene as? UIWindowScene)?
                            .windows
                            .first(where: { $0.isKeyWindow })?
                            .rootViewController
                    }
                    .first?
                    .present(viewController, animated: true)
            }
            if error == nil {
                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
            }
        }
    }

    func submit(result: GameResult) {
        guard isAuthenticated else { return }
        let leaderboardID = leaderboardID(for: result.mode)
        let value = result.mode == .sprint ? Int((result.duration * 1000).rounded()) : result.score
        GKLeaderboard.submitScore(
            value,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { _ in }
        reportAchievements(for: result)
    }

    private func leaderboardID(for mode: GameMode) -> String {
        switch mode {
        case .classic: return "leaderboard_classic_score"
        case .sprint: return "leaderboard_sprint_time_ms"
        case .endless: return "leaderboard_endless_score"
        }
    }

    private func reportAchievements(for result: GameResult) {
        let mappings: [(String, Double)] = [
            ("achievement_lines_100", min(100, Double(result.lines)) / 100.0 * 100.0),
            ("achievement_score_100k", min(100_000, Double(result.score)) / 100_000.0 * 100.0)
        ]
        let achievements = mappings.map { id, progress -> GKAchievement in
            let achievement = GKAchievement(identifier: id)
            achievement.percentComplete = progress
            achievement.showsCompletionBanner = true
            return achievement
        }
        GKAchievement.report(achievements) { _ in }
    }
}
