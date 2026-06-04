import UIKit

final class GameBoardView: UIView {
    private var snapshot: TetrisSnapshot?
    private var theme: AppTheme = .from(.neon)

    func render(snapshot: TetrisSnapshot, theme: AppTheme) {
        self.snapshot = snapshot
        self.theme = theme
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let snapshot, let context = UIGraphicsGetCurrentContext() else { return }
        let boardGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: theme.isRetro
                ? [theme.boardBackground.cgColor, theme.boardBackground.withAlphaComponent(0.92).cgColor] as CFArray
                : [theme.boardBackground.cgColor, theme.panel.withAlphaComponent(0.85).cgColor] as CFArray,
            locations: [0, 1]
        )
        if let boardGradient {
            context.drawLinearGradient(
                boardGradient,
                start: CGPoint(x: rect.minX, y: rect.minY),
                end: CGPoint(x: rect.maxX, y: rect.maxY),
                options: []
            )
        } else {
            context.setFillColor(theme.boardBackground.cgColor)
            context.fill(rect)
        }

        let rows = snapshot.board.rows
        let cols = snapshot.board.columns
        let cellSize = min(rect.width / CGFloat(cols), rect.height / CGFloat(rows))
        let originX = (rect.width - (CGFloat(cols) * cellSize)) / 2
        let originY = (rect.height - (CGFloat(rows) * cellSize)) / 2

        func drawCell(_ point: GridPoint, color: UIColor, alpha: CGFloat = 1) {
            let frame = CGRect(
                x: originX + CGFloat(point.col) * cellSize,
                y: originY + CGFloat(point.row) * cellSize,
                width: cellSize,
                height: cellSize
            ).insetBy(dx: 1, dy: 1)
            let path = UIBezierPath(roundedRect: frame, cornerRadius: max(2, cellSize * 0.2))
            context.saveGState()
            context.addPath(path.cgPath)
            context.clip()
            let top = color.withAlphaComponent(alpha)
            let bottom = color.withAlphaComponent(alpha).withAlphaComponent(alpha * 0.78)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [top.cgColor, bottom.cgColor] as CFArray,
                locations: [0, 1]
            )
            if let gradient {
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: frame.minX, y: frame.minY),
                    end: CGPoint(x: frame.maxX, y: frame.maxY),
                    options: []
                )
            }
            context.restoreGState()
            context.setStrokeColor((theme.isRetro ? UIColor.black : UIColor.white).withAlphaComponent(0.14 * alpha).cgColor)
            context.setLineWidth(max(theme.isRetro ? 1.2 : 1, cellSize * (theme.isRetro ? 0.07 : 0.04)))
            context.addPath(path.cgPath)
            context.strokePath()
        }

        for (point, type) in snapshot.board.settled {
            drawCell(point, color: TetrominoPalette.color(for: type, theme: theme))
        }
        for point in snapshot.ghost.blocks {
            drawCell(point, color: TetrominoPalette.color(for: snapshot.ghost.type, theme: theme), alpha: theme.ghostAlpha)
        }
        for point in snapshot.active.blocks {
            drawCell(point, color: TetrominoPalette.color(for: snapshot.active.type, theme: theme))
        }

        context.setStrokeColor((theme.isRetro ? UIColor.black : UIColor.white).withAlphaComponent(theme.isRetro ? 0.08 : 0.05).cgColor)
        context.setLineWidth(theme.isRetro ? 0.8 : 0.5)
        for row in 0...rows {
            let y = originY + CGFloat(row) * cellSize
            context.move(to: CGPoint(x: originX, y: y))
            context.addLine(to: CGPoint(x: originX + CGFloat(cols) * cellSize, y: y))
        }
        for col in 0...cols {
            let x = originX + CGFloat(col) * cellSize
            context.move(to: CGPoint(x: x, y: originY))
            context.addLine(to: CGPoint(x: x, y: originY + CGFloat(rows) * cellSize))
        }
        context.strokePath()
    }
}
