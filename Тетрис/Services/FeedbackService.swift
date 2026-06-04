import AVFoundation
import UIKit

enum FeedbackEvent {
    case move
    case rotate
    case lock
    case lineClear
    case levelUp
    case gameOver
}

final class FeedbackService {
    private var player: AVAudioPlayer?
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        impact.prepare()
        notification.prepare()
    }

    func play(event: FeedbackEvent, settings: PlayerSettings) {
        guard settings.sfxEnabled || settings.hapticsEnabled else { return }
        if settings.hapticsEnabled {
            switch event {
            case .move, .rotate:
                impact.impactOccurred(intensity: 0.45)
            case .lock:
                impact.impactOccurred(intensity: 0.8)
            case .lineClear, .levelUp:
                notification.notificationOccurred(.success)
            case .gameOver:
                notification.notificationOccurred(.warning)
            }
        }
    }

    func updateBackgroundMusic(enabled: Bool) {
        guard enabled else {
            player?.stop()
            return
        }
        // Music file can be added later without touching gameplay code.
        guard let url = Bundle.main.url(forResource: "bgm_loop", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = 0.25
        player?.play()
    }
}
