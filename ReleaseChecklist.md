# Blocktide — Release Checklist

Статусы: [x] сделано (автоматически в этой сессии) · [ ] за тобой.

## Технические правки для подачи (применены автоматически)
- [x] Bundle ID заменён на валидный `com.nikrev.blockfall` (Debug + Release).
- [x] `CFBundleDisplayName = Blocktide` и `ITSAppUsesNonExemptEncryption = false` в Info.plist.
- [x] Добавлен `PrivacyInfo.xcprivacy` (UserDefaults, причина CA92.1).
- [x] Deployment target 26.2 → 17.0 (нужна контрольная сборка на iOS 17).
- [x] Убран товарный знак «Tetris/тетрис» из UI и метаданных; бренд сведён к Blocktide.
- [x] Иконка 1024×1024 добавлена (плейсхолдер, можно заменить).

## Ручные шаги перед подачей
- [ ] Xcode → Signing & Capabilities → добавить **Game Center** capability.
- [ ] Контрольная сборка и запуск на iOS 17 (симулятор/устройство), без крашей.
- [ ] Game Center в App Store Connect: завести leaderboards/achievements с ID из кода.
- [ ] Захостить Privacy Policy и Support, вставить рабочие https-URL в листинг.
- [ ] Скриншоты iPhone 6.9″ и iPad 13″ по `Screenshots_Plan.md`.

## Product readiness
- [ ] Classic, Sprint, Endless без крашей на iPhone и iPad.
- [ ] Hold, next-очередь, hard drop, мягкое движение, пауза/резюм проверены.
- [ ] Онбординг показывается один раз при первом запуске.
- [ ] Настройки сохраняются (тема, музыка, SFX, вибрация).

## Visual and UX polish
- [ ] Темы Neon, Retro, Minimal Dark проверены на реальных устройствах.
- [ ] Контраст текста и Dynamic Type читаемы.
- [ ] У основных действий есть тактильная и визуальная отдача.
- [ ] Экраны Game Over и завершения Sprint понятны и не блокируют.

## Online services
- [ ] Аутентификация Game Center работает.
- [ ] Leaderboards принимают результат во всех трёх режимах.
- [ ] Достижения засчитывают прогресс и показывают баннер.
- [ ] Офлайн-фолбэк хранит локальную статистику и повторяет отправку позже.

## Performance and quality
- [ ] Смоук-тесты проходят (`EngineSelfTests.runSmokeChecks()` в Debug).
- [ ] 15-минутный прогон без скачков памяти.
- [ ] Переходы background/foreground не роняют приложение.
- [ ] Аудио-сессия корректно ведёт себя при прерываниях.

## App Store Connect prep
- [ ] Иконка, скриншоты (iPhone + iPad), опциональный app preview готовы.
- [ ] Описание, ключевые слова, Support URL, Privacy Policy URL заполнены.
- [ ] Номера версии/сборки выставлены для релиза.
- [ ] Подпись и capabilities проверены для Release-сборки.
