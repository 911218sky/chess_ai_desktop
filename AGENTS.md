# chess_ai_desktop Agent Guide

This file is the working entry point for the `chess_ai_desktop` subproject.
Before making changes, read this file first, then read the task-relevant docs
and source files.

## Read First

1. `../AGENTS.md`
   - Workspace-wide rules and the three-phase workflow: `分析問題`,
     `制定方案`, `執行方案`.
2. `docs/ui-style-guide.md`
   - UI visual direction, layout rules, and design guidance for the chess board
     and right-side control panel.
3. `docs/theme-scene-prompts.md`
   - Image-generation prompts, asset naming rules, and expansion workflow for
     board theme scene backgrounds.

## Common Source Entry Points

- `lib/src/app.dart`
  - Main screen layout, backdrop scene, board workspace, and player/opponent
    information.
- `lib/src/theme/board_theme.dart`
  - Board theme catalog. Update this first when adding themes, backdrop images,
    or board color palettes.
- `lib/src/widgets/chess_board.dart`
  - Board squares, pieces, move hints, selection state, and legal-target
    rendering.
- `lib/src/widgets/control_panel.dart`
  - Right-side control panel, Bot/Match/Coach/LLM tabs, and theme picker UI.
- `lib/src/controllers/game_controller.dart`
  - Game state and interaction flow.
- `lib/src/models/session_config.dart`
  - Match configuration model, including `boardTheme`.

## Theme And Image Asset Rules

- Store scene backdrop images in `assets/chess/themes/`.
- Store chess piece images under `assets/chess/pieces/`; do not delete existing
  SVG/PNG assets casually.
- When adding a new theme, update all of these:
  - `BoardThemeId`
  - `BoardThemeId.label`
  - `BoardThemeId.localizedLabel`
  - `boardThemeStyles`
  - `docs/theme-scene-prompts.md`
- `pubspec.yaml` already declares `assets/chess/themes/`, so adding images to
  that folder usually does not require another pubspec change.
- Generated images must be 16:9, with no text, no watermark, no people, and no
  chess pieces. Keep the center low-distraction and place detail near the edges.

## Workflow Requirements

- For medium or large tasks, start with `【分析問題】`; do not jump straight into
  code changes.
- Before changing UI, verify the change fits `docs/ui-style-guide.md`.
- Before changing themes or generating images, read
  `docs/theme-scene-prompts.md`.
- After implementation, run at least:
  - `dart format <changed dart files>`
  - `flutter analyze`
  - `flutter test`
- Do not run `git commit` or `git push` unless explicitly asked.
- Do not start a development server unless explicitly asked.
