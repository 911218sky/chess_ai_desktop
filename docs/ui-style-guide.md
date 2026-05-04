# Chess AI Desktop UI Style Guide

This guide is the source of truth for future UI work in `chess_ai_desktop`.
When adding or changing UI, keep the app in this style unless the user explicitly
asks for a redesign.

## Product Feel

Chess AI Desktop should feel like a polished desktop chess game lobby, not a
developer analysis dashboard. The reference direction is a "play bots" screen:
the user picks a memorable opponent, sees a large board, and can start or adjust
a match quickly.

Core adjectives:

- Game-like
- Focused
- Premium desktop
- Warm dark
- Character-driven
- Fast to scan

Avoid making the app feel like:

- A SaaS admin panel
- A code/debug console
- A dense Stockfish analysis tool
- A marketing landing page
- A generic Material demo

## Layout Rules

- Keep the chess board visually dominant on the left.
- Keep the right panel as the main interaction hub.
- Use a two-column desktop layout on wide screens:
  - Left: opponent strip, large board, player strip.
  - Right: bot speech, bot roster, match settings, coach, and LLM controls.
- On narrower windows, stack board above controls while preserving the same
  visual hierarchy.
- Do not scatter settings across the whole screen. Keep them grouped inside the
  right panel tabs or a deliberate settings surface.
- Keep the primary action at the bottom of the right panel. The main button
  should stay large, obvious, and game-like.

## Current Visual Language

The current UI uses a warm dark arena:

- App background: near-black green/charcoal.
- Panels: slightly raised dark green-gray.
- Primary accent: chess.com-like fresh green.
- Text: warm off-white.
- Bot accents: profile-dependent bright tones.
- Board: warm wood by default, with alternate board themes available.

Use existing constants in `lib/src/theme/app_theme.dart` before introducing new
colors, radii, or shadows.

Key tokens:

- `AppColors.background`: main page base.
- `AppColors.backgroundTop` / `backgroundBottom`: subtle arena gradient.
- `AppColors.panel`: main right panel.
- `AppColors.panelRaised`: elevated surfaces.
- `AppColors.panelInset`: recessed surfaces.
- `AppColors.field`: inputs.
- `AppColors.primary`: main play/action green.
- `AppColors.text`: main readable text.
- `AppRadii.panel`: large panel radius.
- `AppRadii.section`: section radius.
- `AppRadii.control`: buttons and control groups.
- `AppRadii.input`: text fields and dropdowns.

## Color Guidance

- Keep the overall app dark and warm, with green used as the primary action
  color.
- Use white overlays with low alpha for sections, tabs, and inactive controls.
- Use bot-specific accent colors for avatars, selected bot states, badges, and
  personality hints.
- Use the board theme colors only inside the board or board theme picker.
- Do not let purple/blue gradients become the dominant identity.
- Do not introduce large beige, brown, or orange page backgrounds. Wood tones
  belong mainly to the board.
- Avoid pure black panels except for subtle inset or shadow effects.

## Typography

- Use bold, compact text for game-facing labels, bot names, section headings,
  and primary actions.
- Keep headings functional. A right-panel heading should fit the panel, not look
  like a landing-page hero.
- Use one-line truncation for bot names, selected options, and status text when
  horizontal space is limited.
- Keep body text short. The UI should not explain itself with paragraphs.
- Route player-facing labels, status text, bot metadata, board-theme labels, and
  LLM fallback copy through the existing `AppStrings` / localized model helpers.
  Current supported locales are English (`AppLocale.en`) and Traditional
  Chinese (`AppLocale.zhHant`).
- Keep new localized copy concise in both languages, and verify compact controls
  in the Match, Coach, Review, and LLM tabs do not overflow when switched to
  Traditional Chinese.

## Component Style

Main panel:

- Use one raised container with `panelDecoration()`.
- Keep tabs near the top.
- Keep the large Play button pinned near the bottom.
- Do not nest large cards inside large cards. Use section bands for grouped
  controls.

Tabs:

- Use four primary tabs unless the product scope changes:
  - `Bots`
  - `Match`
  - `Coach`
  - `LLM`
- Tabs should look like a segmented control, not browser tabs.

Bot roster:

- Bot selection should feel like choosing an opponent, not setting a numeric
  engine level.
- Show avatar, name, rating, category, and a short personality cue.
- Expanded category sections may show portrait cards.
- Collapsed sections should still show enough identity to invite selection.

Speech bubble:

- Keep the active bot speech near the top of the `Bots` tab.
- Use a light warm bubble against the dark panel for contrast.
- Speech should be short, flavorful, and readable at a glance.
- Do not turn speech into long coaching text. Put analysis in `Coach`.

Controls:

- Prefer segmented pickers for small option sets.
- Prefer dropdowns for larger option sets.
- Prefer square icon buttons for compact repeated actions.
- Use tooltips for icon-only actions.
- Keep inputs in the `LLM` tab; do not expose API-key style fields in the main
  play flow.

Primary action:

- The main `Play` button should be large, green, and full width.
- Disable or change it clearly during AI thinking.
- Secondary actions such as rematch, side switch, and hint toggle should not
  compete visually with `Play`.

## Chess Board

- The board should remain the largest visual object.
- Keep the board square with `AspectRatio(1)`.
- Preserve coordinate labels and move highlights.
- Selected squares, legal targets, capture rings, and last move highlights must
  be visible on both light and dark squares.
- If board theme selection is added, use `BoardThemeStyle` from
  `lib/src/theme/board_theme.dart` instead of hard-coded colors.
- Do not add decorative frames that make the board smaller or harder to play.

## Motion And Feedback

- AI thinking should be visible but calm.
- Use disabled states for controls that cannot be used while the engine is
  thinking.
- Avoid flashy animations that distract from playing chess.
- Small hover, press, and selection feedback is appropriate for desktop.

## Content Tone

- The product voice is playful but concise.
- Bot lines can have personality, but the interface labels should stay clear.
- `Coach` content should be useful and direct.
- `LLM` copy should reassure that gameplay remains local and does not stall if
  text generation fails.

## Do Not Do

- Do not redesign the app into an analysis dashboard unless explicitly asked.
- Do not make the board secondary to metrics or logs.
- Do not replace the bot roster with a plain difficulty form.
- Do not add a marketing hero page.
- Do not use large decorative blobs, abstract SVG scenes, or generic gradients.
- Do not put every setting on the first screen at once.
- Do not create one-off colors when an existing theme token fits.
- Do not add dense engine tables to the main play tab.

## Implementation Checklist For Future AI

Before changing UI, check:

- Does the board remain dominant?
- Does the right panel still feel like a play-bots lobby?
- Is the primary action still obvious?
- Are controls grouped into the correct tab?
- Did you reuse `AppColors`, `AppRadii`, `panelDecoration()`, and
  `BoardThemeStyle` where applicable?
- Are bot identity and personality still visible?
- Is the screen still usable for repeated desktop play?
- Did new user-facing copy use the existing localization path for both English
  and Traditional Chinese?
- Did you avoid dashboard, landing-page, and generic Material-demo patterns?
