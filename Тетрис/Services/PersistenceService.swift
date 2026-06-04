import Foundation

struct PlayerSettings: Codable {
    var selectedTheme: ThemePreset
    var musicEnabled: Bool
    var sfxEnabled: Bool
    var hapticsEnabled: Bool

    static let `default` = PlayerSettings(
        selectedTheme: .neon,
        musicEnabled: true,
        sfxEnabled: true,
        hapticsEnabled: true
    )
}

struct PlayerStats: Codable {
    var totalSessions: Int
    var totalLines: Int
    var bestScoreByMode: [GameMode: Int]
    var bestSprintTime: TimeInterval?
    var totalPlayTime: TimeInterval

    static let `default` = PlayerStats(
        totalSessions: 0,
        totalLines: 0,
        bestScoreByMode: [:],
        bestSprintTime: nil,
        totalPlayTime: 0
    )
}

final class PersistenceService {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Key {
        static let settings = "player_settings_v1"
        static let stats = "player_stats_v1"
        static let didCompleteOnboarding = "did_complete_onboarding_v1"
        static let recentResults = "recent_results_v1"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> PlayerSettings {
        read(PlayerSettings.self, key: Key.settings) ?? .default
    }

    func saveSettings(_ settings: PlayerSettings) {
        write(settings, key: Key.settings)
    }

    func loadStats() -> PlayerStats {
        read(PlayerStats.self, key: Key.stats) ?? .default
    }

    func saveStats(_ stats: PlayerStats) {
        write(stats, key: Key.stats)
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Key.didCompleteOnboarding)
    }

    func shouldShowOnboarding() -> Bool {
        !defaults.bool(forKey: Key.didCompleteOnboarding)
    }

    func saveResult(_ result: GameResult) {
        var results = loadRecentResults()
        results.insert(result, at: 0)
        results = Array(results.prefix(20))
        write(results, key: Key.recentResults)

        var stats = loadStats()
        stats.totalSessions += 1
        stats.totalLines += result.lines
        stats.totalPlayTime += result.duration
        stats.bestScoreByMode[result.mode] = max(stats.bestScoreByMode[result.mode] ?? 0, result.score)
        if result.mode == .sprint, result.didWinSprint {
            let previous = stats.bestSprintTime ?? .infinity
            stats.bestSprintTime = min(previous, result.duration)
        }
        saveStats(stats)
    }

    func loadRecentResults() -> [GameResult] {
        read([GameResult].self, key: Key.recentResults) ?? []
    }

    private func read<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func write<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
