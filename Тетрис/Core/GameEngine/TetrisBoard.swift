import Foundation

struct TetrisBoard {
    let rows: Int
    let columns: Int
    private(set) var settled: [GridPoint: TetrominoType]

    init(rows: Int = 20, columns: Int = 10, settled: [GridPoint: TetrominoType] = [:]) {
        self.rows = rows
        self.columns = columns
        self.settled = settled
    }

    func isInside(_ point: GridPoint) -> Bool {
        point.row >= 0 && point.row < rows && point.col >= 0 && point.col < columns
    }

    func isCellFree(_ point: GridPoint) -> Bool {
        isInside(point) && settled[point] == nil
    }

    func canPlace(_ piece: FallingPiece) -> Bool {
        piece.blocks.allSatisfy { isCellFree($0) }
    }

    mutating func lock(piece: FallingPiece) {
        piece.blocks.forEach { settled[$0] = piece.type }
    }

    mutating func clearLines() -> Int {
        guard !settled.isEmpty else { return 0 }
        let fullRows = (0..<rows).filter { row in
            (0..<columns).allSatisfy { col in settled[GridPoint(row: row, col: col)] != nil }
        }
        guard !fullRows.isEmpty else { return 0 }

        let fullSet = Set(fullRows)
        var newSettled: [GridPoint: TetrominoType] = [:]

        for (point, type) in settled {
            guard !fullSet.contains(point.row) else { continue }
            let droppedBy = fullRows.filter { $0 > point.row }.count
            let newPoint = GridPoint(row: point.row + droppedBy, col: point.col)
            newSettled[newPoint] = type
        }
        settled = newSettled
        return fullRows.count
    }
}
