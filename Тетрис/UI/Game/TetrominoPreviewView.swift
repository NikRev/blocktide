import UIKit

/// Мини-превью одной фигуры тетриса (ромб/форма), без букв.
final class TetrominoPreviewView: UIView {
    var pieceType: TetrominoType? {
        didSet { setNeedsDisplay() }
    }
    var theme: AppTheme = .from(.neon) {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let type = pieceType else { return }
        let blocks = TetrominoShape.blocks(for: type, rotation: 0)
        let cols = blocks.map(\.col)
        let rows = blocks.map(\.row)
        let minC = cols.min() ?? 0
        let maxC = cols.max() ?? 0
        let minR = rows.min() ?? 0
        let maxR = rows.max() ?? 0
        let w = maxC - minC + 1
        let h = maxR - minR + 1
        let cellSize = min(rect.width / CGFloat(max(1, w)), rect.height / CGFloat(max(1, h))) * 0.85
        let originX = rect.midX - (CGFloat(w) * cellSize) / 2
        let originY = rect.midY - (CGFloat(h) * cellSize) / 2
        let color = TetrominoPalette.color(for: type, theme: theme)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        for point in blocks {
            let x = originX + CGFloat(point.col - minC) * cellSize
            let y = originY + CGFloat(point.row - minR) * cellSize
            let frame = CGRect(x: x, y: y, width: cellSize, height: cellSize).insetBy(dx: 1, dy: 1)
            let path = UIBezierPath(roundedRect: frame, cornerRadius: max(1, cellSize * 0.2))
            context.setFillColor(color.cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
            context.setLineWidth(max(0.5, cellSize * 0.08))
            context.addPath(path.cgPath)
            context.strokePath()
        }
    }
}
