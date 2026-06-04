import UIKit

final class GameViewController: UIViewController {
    private let mode: GameMode
    private let services: AppServices
    private var engine: TetrisEngine
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    private let boardView = GameBoardView()
    private let scoreTitleLabel = UILabel()
    private let scoreValueLabel = UILabel()
    private let linesTitleLabel = UILabel()
    private let linesValueLabel = UILabel()
    private let levelTitleLabel = UILabel()
    private let levelValueLabel = UILabel()
    private let nextTitleLabel = UILabel()
    private let nextPiecePreview = TetrominoPreviewView()
    private let holdTitleLabel = UILabel()
    private let holdPiecePreview = TetrominoPreviewView()
    private let hudCard = UIView()
    private let controlsCard = UIView()
    private let backgroundGradient = CAGradientLayer()

    private let rotateButton = StyledButton(title: "game.controls.rotate".localized)
    private let leftButton = StyledButton(title: "game.controls.left".localized)
    private let rightButton = StyledButton(title: "game.controls.right".localized)
    private let dropButton = StyledButton(title: "game.controls.hard_drop".localized)
    private let holdButton = StyledButton(title: "game.controls.hold".localized)
    private let pauseButton = StyledButton(title: "game.controls.pause".localized)

    init(mode: GameMode, services: AppServices) {
        self.mode = mode
        self.services = services
        self.engine = TetrisEngine(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode.title
        setupUI()
        wireActions()
        services.feedback.prepare()
        services.feedback.updateBackgroundMusic(enabled: services.persistence.loadSettings().musicEnabled)
        render()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLoop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.primaryReadableText]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = theme.primaryReadableText
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    private func setupUI() {
        let settings = services.persistence.loadSettings()
        let theme = AppTheme.from(settings.selectedTheme)
        view.layer.insertSublayer(backgroundGradient, at: 0)
        backgroundGradient.colors = [theme.background.cgColor, theme.backgroundSecondary.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0.15, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.85, y: 1)

        let titleFont = theme.isRetro
            ? UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
            : UIFont.systemFont(ofSize: 13, weight: .semibold)
        let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        [scoreTitleLabel, linesTitleLabel, levelTitleLabel, nextTitleLabel, holdTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = theme.secondaryReadableText
            $0.font = titleFont
            $0.textAlignment = .center
        }
        [scoreValueLabel, linesValueLabel, levelValueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = theme.primaryReadableText
            $0.font = valueFont
            $0.textAlignment = .center
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.7
        }
        [nextPiecePreview, holdPiecePreview].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.backgroundColor = theme.boardBackground
        boardView.layer.cornerRadius = 24
        boardView.layer.cornerCurve = .continuous
        boardView.clipsToBounds = true
        boardView.layer.borderWidth = 1
        boardView.layer.borderColor = theme.panelStroke.cgColor
        boardView.layer.shadowColor = theme.shadowColor.cgColor
        boardView.layer.shadowOpacity = 0.4
        boardView.layer.shadowRadius = 24
        boardView.layer.shadowOffset = CGSize(width: 0, height: 12)

        applyControlStyles(theme: theme)
        [leftButton, rightButton].forEach { button in
            button.setImage(UIImage(systemName: button === leftButton ? "arrow.left" : "arrow.right"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 8)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        }
        rotateButton.setImage(UIImage(systemName: "rotate.right.fill"), for: .normal)
        rotateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 8)
        rotateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        dropButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        dropButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 8)
        dropButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)

        let scoreCol = makeHudColumn(title: scoreTitleLabel, valueView: scoreValueLabel)
        let linesCol = makeHudColumn(title: linesTitleLabel, valueView: linesValueLabel)
        let levelCol = makeHudColumn(title: levelTitleLabel, valueView: levelValueLabel)
        let topRow = UIStackView(arrangedSubviews: [scoreCol, linesCol, levelCol])
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 8
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let nextCol = makeHudColumn(title: nextTitleLabel, valueView: nextPiecePreview)
        let holdCol = makeHudColumn(title: holdTitleLabel, valueView: holdPiecePreview)
        let bottomRow = UIStackView(arrangedSubviews: [nextCol, holdCol])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 8
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = theme.panelStroke.withAlphaComponent(0.4)

        let hudStack = UIStackView(arrangedSubviews: [topRow, divider, bottomRow])
        hudStack.axis = .vertical
        hudStack.spacing = 12
        hudStack.translatesAutoresizingMaskIntoConstraints = false

        let controlsTop = UIStackView(arrangedSubviews: [leftButton, rotateButton, rightButton])
        controlsTop.axis = .horizontal
        controlsTop.spacing = 10
        controlsTop.distribution = .fillEqually
        controlsTop.translatesAutoresizingMaskIntoConstraints = false

        let controlsBottom = UIStackView(arrangedSubviews: [dropButton, holdButton, pauseButton])
        controlsBottom.axis = .horizontal
        controlsBottom.spacing = 10
        controlsBottom.distribution = .fillEqually
        controlsBottom.translatesAutoresizingMaskIntoConstraints = false

        hudCard.translatesAutoresizingMaskIntoConstraints = false
        hudCard.layer.cornerRadius = 20
        hudCard.layer.cornerCurve = .continuous
        hudCard.layer.borderWidth = 1
        hudCard.backgroundColor = theme.panel.withAlphaComponent(0.88)
        hudCard.layer.borderColor = theme.panelStroke.cgColor
        hudCard.layer.shadowColor = theme.shadowColor.cgColor
        hudCard.layer.shadowOpacity = 0.2
        hudCard.layer.shadowRadius = 14
        hudCard.layer.shadowOffset = CGSize(width: 0, height: 6)

        controlsCard.translatesAutoresizingMaskIntoConstraints = false
        controlsCard.layer.cornerRadius = 18
        controlsCard.layer.cornerCurve = .continuous
        controlsCard.layer.borderWidth = 1
        controlsCard.backgroundColor = theme.panel.withAlphaComponent(0.72)
        controlsCard.layer.borderColor = theme.panelStroke.cgColor

        view.addSubview(hudCard)
        hudCard.addSubview(hudStack)
        view.addSubview(boardView)
        view.addSubview(controlsCard)
        controlsCard.addSubview(controlsTop)
        controlsCard.addSubview(controlsBottom)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            hudCard.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            hudCard.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            hudCard.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),

            hudStack.topAnchor.constraint(equalTo: hudCard.topAnchor, constant: 14),
            hudStack.leadingAnchor.constraint(equalTo: hudCard.leadingAnchor, constant: 14),
            hudStack.trailingAnchor.constraint(equalTo: hudCard.trailingAnchor, constant: -14),
            hudStack.bottomAnchor.constraint(equalTo: hudCard.bottomAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),
            nextPiecePreview.widthAnchor.constraint(equalToConstant: 44),
            nextPiecePreview.heightAnchor.constraint(equalToConstant: 44),
            holdPiecePreview.widthAnchor.constraint(equalToConstant: 44),
            holdPiecePreview.heightAnchor.constraint(equalToConstant: 44),

            boardView.topAnchor.constraint(equalTo: hudCard.bottomAnchor, constant: 12),
            boardView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            boardView.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: 8),
            boardView.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -8),
            boardView.widthAnchor.constraint(lessThanOrEqualTo: guide.widthAnchor, constant: -16),

            controlsCard.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 14),
            controlsCard.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            controlsCard.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            controlsCard.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -10),

            controlsTop.topAnchor.constraint(equalTo: controlsCard.topAnchor, constant: 12),
            controlsTop.leadingAnchor.constraint(equalTo: controlsCard.leadingAnchor, constant: 12),
            controlsTop.trailingAnchor.constraint(equalTo: controlsCard.trailingAnchor, constant: -12),

            controlsBottom.topAnchor.constraint(equalTo: controlsTop.bottomAnchor, constant: 10),
            controlsBottom.leadingAnchor.constraint(equalTo: controlsTop.leadingAnchor),
            controlsBottom.trailingAnchor.constraint(equalTo: controlsTop.trailingAnchor),
            controlsBottom.bottomAnchor.constraint(equalTo: controlsCard.bottomAnchor, constant: -12)
        ])
        let aspect = boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 2)
        aspect.priority = .defaultHigh
        aspect.isActive = true
        let preferredWidth = boardView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.9)
        preferredWidth.priority = .defaultHigh
        preferredWidth.isActive = true
        boardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true
        boardView.heightAnchor.constraint(lessThanOrEqualTo: guide.heightAnchor, multiplier: 0.72).isActive = true
        [leftButton, rightButton, rotateButton, holdButton, dropButton, pauseButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }

        let leftTap = UITapGestureRecognizer(target: self, action: #selector(didTapLeft))
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(didTapRight))
        leftTap.numberOfTouchesRequired = 1
        rightTap.numberOfTouchesRequired = 1
        leftTap.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        rightTap.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        leftTap.cancelsTouchesInView = false
        rightTap.cancelsTouchesInView = false
        leftTap.delegate = self
        rightTap.delegate = self
        boardView.addGestureRecognizer(leftTap)
        boardView.addGestureRecognizer(rightTap)

        let hardDropSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        hardDropSwipe.direction = .up
        boardView.addGestureRecognizer(hardDropSwipe)
    }

    private func wireActions() {
        rotateButton.addTarget(self, action: #selector(didTapRotate), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)
        dropButton.addTarget(self, action: #selector(didTapDrop), for: .touchUpInside)
        holdButton.addTarget(self, action: #selector(didTapHold), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(didTapPause), for: .touchUpInside)
    }

    private func startLoop() {
        stopLoop()
        let link = CADisplayLink(target: self, selector: #selector(loop))
        link.add(to: .main, forMode: .common)
        displayLink = link
        lastTimestamp = 0
    }

    private func stopLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func loop(_ link: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = link.timestamp; return }
        let delta = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        let events = engine.tick(deltaTime: delta)
        handle(events: events)
        render()
    }

    private func handle(events: [EngineEvent]) {
        let settings = services.persistence.loadSettings()
        events.forEach { event in
            switch event {
            case .moved:
                services.feedback.play(event: .move, settings: settings)
            case .rotated:
                services.feedback.play(event: .rotate, settings: settings)
            case .locked:
                services.feedback.play(event: .lock, settings: settings)
            case .linesCleared:
                services.feedback.play(event: .lineClear, settings: settings)
            case .levelUp:
                services.feedback.play(event: .levelUp, settings: settings)
            case .gameOver, .sprintFinished:
                services.feedback.play(event: .gameOver, settings: settings)
                finishGame()
            }
        }
    }

    private func finishGame() {
        stopLoop()
        let result = engine.currentResult()
        services.persistence.saveResult(result)
        services.gameCenter.submit(result: result)
        let theme = AppTheme.from(services.persistence.loadSettings().selectedTheme)
        let results = GameResultViewController(
            result: result,
            theme: theme,
            onReplay: { [weak self] in
                self?.engine.restart()
                self?.render()
                self?.startLoop()
            },
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        present(results, animated: true)
    }

    private func render() {
        let snapshot = engine.snapshot()
        let settings = services.persistence.loadSettings()
        let theme = AppTheme.from(settings.selectedTheme)
        backgroundGradient.colors = [theme.background.cgColor, theme.backgroundSecondary.cgColor]
        hudCard.backgroundColor = theme.panel.withAlphaComponent(0.82)
        hudCard.layer.borderColor = theme.panelStroke.cgColor
        controlsCard.backgroundColor = theme.panel.withAlphaComponent(0.72)
        controlsCard.layer.borderColor = theme.panelStroke.cgColor
        applyControlStyles(theme: theme)
        [scoreTitleLabel, linesTitleLabel, levelTitleLabel, nextTitleLabel, holdTitleLabel].forEach {
            $0.textColor = theme.secondaryReadableText
        }
        [scoreValueLabel, linesValueLabel, levelValueLabel].forEach {
            $0.textColor = theme.primaryReadableText
        }
        boardView.render(snapshot: snapshot, theme: theme)
        scoreTitleLabel.text = "game.hud.score".localized
        scoreValueLabel.text = "\(snapshot.score)"
        linesTitleLabel.text = "game.hud.lines".localized
        linesValueLabel.text = "\(snapshot.lines)"
        levelTitleLabel.text = "game.hud.level".localized
        levelValueLabel.text = "\(snapshot.level)"
        nextTitleLabel.text = "game.hud.next".localized
        nextPiecePreview.pieceType = snapshot.next.first
        nextPiecePreview.theme = theme
        holdTitleLabel.text = "game.hud.hold".localized
        holdPiecePreview.pieceType = snapshot.hold
        holdPiecePreview.theme = theme
        pauseButton.setTitle(snapshot.isPaused ? "game.controls.resume".localized : "game.controls.pause".localized, for: .normal)
        if theme.isRetro {
            title = "\(mode.title) LCD"
        } else {
            title = mode.title
        }
    }

    @objc private func didTapLeft() {
        if engine.moveLeft() {
            services.feedback.play(event: .move, settings: services.persistence.loadSettings())
            render()
        }
    }

    @objc private func didTapRight() {
        if engine.moveRight() {
            services.feedback.play(event: .move, settings: services.persistence.loadSettings())
            render()
        }
    }

    @objc private func didSwipeUp() {
        let events = engine.hardDrop()
        handle(events: events)
        render()
    }

    @objc private func didTapRotate() {
        if engine.rotate() {
            services.feedback.play(event: .rotate, settings: services.persistence.loadSettings())
            render()
        }
    }

    @objc private func didTapDrop() {
        let events = engine.hardDrop()
        handle(events: events)
        render()
    }

    @objc private func didTapHold() {
        if engine.hold() {
            render()
        }
    }

    @objc private func didTapPause() {
        engine.togglePause()
        render()
    }

    private func makeHudColumn(title: UILabel, valueView: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [title, valueView])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }

    private func applyControlStyles(theme: AppTheme) {
        let retroRotateTheme = theme.withAccent(
            UIColor(red: 0.18, green: 0.7, blue: 0.95, alpha: 1),
            secondary: UIColor(red: 0.13, green: 0.48, blue: 0.86, alpha: 1)
        )

        if theme.isRetro {
            [leftButton, rightButton, dropButton, holdButton, pauseButton].forEach { $0.apply(theme: theme) }
            rotateButton.apply(theme: retroRotateTheme)
            holdButton.apply(theme: theme, emphasized: false)
            pauseButton.apply(theme: theme, emphasized: false)
        } else {
            [leftButton, rotateButton, rightButton, dropButton].forEach { $0.apply(theme: theme) }
            holdButton.apply(theme: theme, emphasized: false)
            pauseButton.apply(theme: theme, emphasized: false)
        }
    }
}

extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let x = touch.location(in: boardView).x
        let shouldGoLeft = x < boardView.bounds.width / 2
        if shouldGoLeft {
            didTapLeft()
        } else {
            didTapRight()
        }
        return false
    }
}
