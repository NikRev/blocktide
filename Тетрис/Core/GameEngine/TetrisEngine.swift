import Foundation

enum EngineEvent {
    case moved
    case rotated
    case locked
    case linesCleared(Int)
    case levelUp(Int)
    case gameOver
    case sprintFinished
}

struct TetrisSnapshot {
    let board: TetrisBoard
    let active: FallingPiece
    let ghost: FallingPiece
    let hold: TetrominoType?
    let next: [TetrominoType]
    let score: Int
    let lines: Int
    let level: Int
    let elapsed: TimeInterval
    let mode: GameMode
    let isGameOver: Bool
    let isPaused: Bool
}

final class TetrisEngine {
    private(set) var board = TetrisBoard()
    private(set) var activePiece: FallingPiece
    private(set) var holdPiece: TetrominoType?
    private(set) var nextQueue: [TetrominoType] = []
    private(set) var score = 0
    private(set) var linesCleared = 0
    private(set) var level = 1
    private(set) var isGameOver = false
    private(set) var isPaused = false

    let mode: GameMode
    let rules: GameModeRules

    private var hasUsedHoldInTurn = false
    private var bag: [TetrominoType] = []
    private var randomNumberGenerator: SeededGenerator
    private var elapsed: TimeInterval = 0
    private var dropAccumulator: TimeInterval = 0
    private var didFinishSprint = false

    init(mode: GameMode, seed: UInt64 = UInt64.random(in: 1...UInt64.max)) {
        let bootstrap = Self.bootstrapPieces(seed: seed, queueSize: 7)
        self.mode = mode
        self.rules = .forMode(mode)
        self.randomNumberGenerator = bootstrap.generator
        self.bag = bootstrap.bag
        self.activePiece = Self.spawnPiece(type: bootstrap.firstPiece, boardColumns: 10)
        self.nextQueue = bootstrap.queue
    }

    func snapshot() -> TetrisSnapshot {
        TetrisSnapshot(
            board: board,
            active: activePiece,
            ghost: ghostPiece(),
            hold: holdPiece,
            next: Array(nextQueue.prefix(5)),
            score: score,
            lines: linesCleared,
            level: level,
            elapsed: elapsed,
            mode: mode,
            isGameOver: isGameOver,
            isPaused: isPaused
        )
    }

    func restart(seed: UInt64 = UInt64.random(in: 1...UInt64.max)) {
        board = TetrisBoard()
        holdPiece = nil
        nextQueue = []
        score = 0
        linesCleared = 0
        level = 1
        isGameOver = false
        isPaused = false
        hasUsedHoldInTurn = false
        bag = []
        randomNumberGenerator = SeededGenerator(seed: seed)
        elapsed = 0
        dropAccumulator = 0
        didFinishSprint = false
        refillBagIfNeeded()
        activePiece = Self.spawnPiece(type: drawNextType(), boardColumns: board.columns)
        enqueuePieces()
    }

    func togglePause() {
        guard !isGameOver else { return }
        isPaused.toggle()
    }

    @discardableResult
    func tick(deltaTime: TimeInterval) -> [EngineEvent] {
        guard !isPaused && !isGameOver else { return [] }
        elapsed += deltaTime
        dropAccumulator += deltaTime
        var events: [EngineEvent] = []
        while dropAccumulator >= dropInterval {
            dropAccumulator -= dropInterval
            if move(rowDelta: 1, colDelta: 0) {
                events.append(.moved)
            } else {
                events.append(contentsOf: lockCurrentPiece())
                if isGameOver || didFinishSprint {
                    break
                }
            }
        }
        return events
    }

    @discardableResult
    func moveLeft() -> Bool { move(rowDelta: 0, colDelta: -1) }

    @discardableResult
    func moveRight() -> Bool { move(rowDelta: 0, colDelta: 1) }

    @discardableResult
    func softDrop() -> [EngineEvent] {
        guard !isPaused && !isGameOver else { return [] }
        if move(rowDelta: 1, colDelta: 0) {
            score += 1
            return [.moved]
        }
        return lockCurrentPiece()
    }

    @discardableResult
    func hardDrop() -> [EngineEvent] {
        guard !isPaused && !isGameOver else { return [] }
        var distance = 0
        while move(rowDelta: 1, colDelta: 0) {
            distance += 1
        }
        score += distance * 2
        return lockCurrentPiece()
    }

    @discardableResult
    func rotate() -> Bool {
        guard !isPaused && !isGameOver else { return false }
        var candidate = activePiece
        candidate.rotation += 1
        if board.canPlace(candidate) {
            activePiece = candidate
            return true
        }
        // Basic wall-kick attempts.
        for offset in [-1, 1, -2, 2] {
            var kicked = candidate
            kicked.originCol += offset
            if board.canPlace(kicked) {
                activePiece = kicked
                return true
            }
        }
        return false
    }

    @discardableResult
    func hold() -> Bool {
        guard !isPaused && !isGameOver && !hasUsedHoldInTurn else { return false }
        hasUsedHoldInTurn = true
        let currentType = activePiece.type
        if let holdPiece {
            activePiece = Self.spawnPiece(type: holdPiece, boardColumns: board.columns)
            self.holdPiece = currentType
        } else {
            self.holdPiece = currentType
            activePiece = Self.spawnPiece(type: popFromQueue(), boardColumns: board.columns)
        }
        if !board.canPlace(activePiece) {
            isGameOver = true
            return false
        }
        return true
    }

    func currentResult() -> GameResult {
        GameResult(
            mode: mode,
            score: score,
            lines: linesCleared,
            level: level,
            duration: elapsed,
            createdAt: Date(),
            didWinSprint: didFinishSprint
        )
    }

    private var dropInterval: TimeInterval {
        guard rules.allowsLeveling else { return rules.initialDropInterval }
        let interval = rules.initialDropInterval - (Double(level - 1) * 0.05)
        return max(rules.minimumDropInterval, interval)
    }

    private func move(rowDelta: Int, colDelta: Int) -> Bool {
        guard !isPaused && !isGameOver else { return false }
        var candidate = activePiece
        candidate.originRow += rowDelta
        candidate.originCol += colDelta
        guard board.canPlace(candidate) else { return false }
        activePiece = candidate
        return true
    }

    private func lockCurrentPiece() -> [EngineEvent] {
        var events: [EngineEvent] = [.locked]
        board.lock(piece: activePiece)
        let cleared = board.clearLines()
        if cleared > 0 {
            let scoreGain: Int
            switch cleared {
            case 1: scoreGain = 100
            case 2: scoreGain = 300
            case 3: scoreGain = 500
            default: scoreGain = 800
            }
            score += scoreGain * level
            linesCleared += cleared
            events.append(.linesCleared(cleared))
            maybeLevelUp(events: &events)
            maybeFinishSprint(events: &events)
        }

        hasUsedHoldInTurn = false
        activePiece = Self.spawnPiece(type: popFromQueue(), boardColumns: board.columns)
        if !board.canPlace(activePiece) {
            isGameOver = true
            events.append(.gameOver)
        }
        return events
    }

    private func maybeLevelUp(events: inout [EngineEvent]) {
        guard rules.allowsLeveling else { return }
        let newLevel = max(1, (linesCleared / rules.levelStepLines) + 1)
        guard newLevel > level else { return }
        level = newLevel
        events.append(.levelUp(level))
    }

    private func maybeFinishSprint(events: inout [EngineEvent]) {
        guard mode == .sprint, let target = rules.sprintTargetLines, linesCleared >= target, !didFinishSprint else { return }
        didFinishSprint = true
        isGameOver = true
        events.append(.sprintFinished)
    }

    private func ghostPiece() -> FallingPiece {
        var ghost = activePiece
        while true {
            var next = ghost
            next.originRow += 1
            if board.canPlace(next) {
                ghost = next
            } else {
                return ghost
            }
        }
    }

    private static func spawnPiece(type: TetrominoType, boardColumns: Int) -> FallingPiece {
        FallingPiece(type: type, rotation: 0, originRow: 0, originCol: (boardColumns / 2) - 1)
    }

    private static func bootstrapPieces(seed: UInt64, queueSize: Int) -> (generator: SeededGenerator, bag: [TetrominoType], firstPiece: TetrominoType, queue: [TetrominoType]) {
        var generator = SeededGenerator(seed: seed)
        var bag: [TetrominoType] = []
        var queue: [TetrominoType] = []

        func draw() -> TetrominoType {
            if bag.isEmpty {
                bag = TetrominoType.allCases.shuffled(using: &generator)
            }
            return bag.removeFirst()
        }

        let first = draw()
        while queue.count < queueSize {
            queue.append(draw())
        }
        return (generator, bag, first, queue)
    }

    private func enqueuePieces() {
        while nextQueue.count < 7 {
            nextQueue.append(drawNextType())
        }
    }

    private func popFromQueue() -> TetrominoType {
        enqueuePieces()
        let first = nextQueue.removeFirst()
        enqueuePieces()
        return first
    }

    private func drawNextType() -> TetrominoType {
        refillBagIfNeeded()
        return bag.removeFirst()
    }

    private func refillBagIfNeeded() {
        guard bag.isEmpty else { return }
        bag = TetrominoType.allCases.shuffled(using: &randomNumberGenerator)
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
