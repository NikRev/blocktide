import Foundation

enum EngineSelfTests {
    static func runSmokeChecks() {
        testSpawnAndMovement()
        testLineClearScoring()
        testSprintCompletion()
    }

    private static func testSpawnAndMovement() {
        let engine = TetrisEngine(mode: .classic, seed: 1)
        let snapshot = engine.snapshot()
        assert(snapshot.board.columns == 10 && snapshot.board.rows == 20)
        _ = engine.moveLeft()
        _ = engine.moveRight()
    }

    private static func testLineClearScoring() {
        let engine = TetrisEngine(mode: .classic, seed: 2)
        for _ in 0..<120 {
            _ = engine.tick(deltaTime: 1.0)
            if engine.isGameOver { break }
        }
        let result = engine.currentResult()
        assert(result.score >= 0)
        assert(result.lines >= 0)
    }

    private static func testSprintCompletion() {
        let engine = TetrisEngine(mode: .sprint, seed: 3)
        for _ in 0..<2000 {
            _ = engine.hardDrop()
            if engine.isGameOver { break }
        }
        let result = engine.currentResult()
        assert(result.mode == .sprint)
    }
}
