import Foundation

final class AppServices {
    let persistence: PersistenceService
    let feedback: FeedbackService
    let gameCenter: GameCenterService

    init(
        persistence: PersistenceService = PersistenceService(),
        feedback: FeedbackService = FeedbackService(),
        gameCenter: GameCenterService = GameCenterService()
    ) {
        self.persistence = persistence
        self.feedback = feedback
        self.gameCenter = gameCenter
    }
}
