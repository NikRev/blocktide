import Foundation

struct GridPoint: Hashable {
    let row: Int
    let col: Int

    func translated(row deltaRow: Int, col deltaCol: Int) -> GridPoint {
        GridPoint(row: row + deltaRow, col: col + deltaCol)
    }

    nonisolated static func == (lhs: GridPoint, rhs: GridPoint) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
}

enum TetrominoType: CaseIterable, Codable {
    case i, o, t, s, z, j, l
}

struct FallingPiece {
    var type: TetrominoType
    var rotation: Int
    var originRow: Int
    var originCol: Int

    var blocks: [GridPoint] {
        TetrominoShape.blocks(for: type, rotation: rotation).map {
            $0.translated(row: originRow, col: originCol)
        }
    }
}

enum TetrominoShape {
    static func blocks(for type: TetrominoType, rotation: Int) -> [GridPoint] {
        let normalized = ((rotation % 4) + 4) % 4
        let base = basePoints(for: type)
        return base.map { rotate(point: $0, times: normalized) }
    }

    private static func rotate(point: GridPoint, times: Int) -> GridPoint {
        var current = point
        for _ in 0..<times {
            current = GridPoint(row: current.col, col: -current.row)
        }
        return current
    }

    private static func basePoints(for type: TetrominoType) -> [GridPoint] {
        switch type {
        case .i:
            return [GridPoint(row: 0, col: -1), GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 0, col: 2)]
        case .o:
            return [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)]
        case .t:
            return [GridPoint(row: 0, col: -1), GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 1, col: 0)]
        case .s:
            return [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 1, col: -1), GridPoint(row: 1, col: 0)]
        case .z:
            return [GridPoint(row: 0, col: -1), GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)]
        case .j:
            return [GridPoint(row: 0, col: -1), GridPoint(row: 1, col: -1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)]
        case .l:
            return [GridPoint(row: 0, col: 1), GridPoint(row: 1, col: -1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)]
        }
    }
}
