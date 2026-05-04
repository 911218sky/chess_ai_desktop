# Theme Scene Image Prompts

This document stores reusable image-generation prompts for `chess_ai_desktop`
board themes. Use these prompts when generating new scene backdrops or when
creating variants that should match the current app style.

## Asset Rules

- Save generated theme images under `assets/chess/themes/`.
- Declare the folder in `pubspec.yaml` with `assets/chess/themes/`.
- Register each image in `lib/src/theme/board_theme.dart` through
  `BoardThemeStyle.backdropAsset`.
- Keep images as 16:9 landscape backdrops for desktop UI.
- Keep the center calm and lower-contrast because the chess board and panels sit
  above the image.
- Do not include readable text, logos, watermarks, people, animals, UI mockups,
  or actual chess pieces in the background.
- Prefer decorative detail at the edges and calmer contrast in the center.

## Base Prompt Template

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: <scene name> chess arena backdrop
Scene/backdrop: <specific environment>, subtle chess-board geometry integrated
into the floor or ground, decorative detail at the edges
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: <scene-specific mood>, premium strategy game atmosphere
Color palette: <scene-specific palette>
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

## Current Theme Prompts

### Classic Wood

Theme ID: `BoardThemeId.classicWood`

Asset: `assets/chess/themes/classic-wood-club.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: classic wood chess club arena backdrop
Scene/backdrop: warm traditional chess club room with polished wooden table
surfaces, soft shelves and architectural wood panels at the edges, subtle
chess-board geometry in the floor and tabletop reflections
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: cozy amber lamplight, classic premium chess atmosphere
Color palette: honey wood, walnut brown, warm amber, dark coffee shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Tournament Green

Theme ID: `BoardThemeId.tournamentGreen`

Asset: `assets/chess/themes/tournament-green-hall.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: tournament green chess arena backdrop
Scene/backdrop: modern quiet tournament hall, green felt accents, soft overhead
lights, blurred score-table shapes at edges, subtle chess-board geometry on a
clean stage floor
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: focused professional tournament atmosphere, restrained and
elegant
Color palette: tournament green, cream, charcoal, muted brass highlights
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals, no readable signs; background must remain usable behind a chessboard
and panels
```

### Ocean Slate

Theme ID: `BoardThemeId.oceanSlate`

Asset: `assets/chess/themes/ocean-slate-terrace.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: ocean slate chess arena backdrop
Scene/backdrop: stormy coastal slate chess terrace, dark blue stone floor with
subtle chess-board geometry, misty ocean horizon, wet slate pillars and soft
wave light at edges
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: cool dramatic coastal evening, calm premium strategy atmosphere
Color palette: slate blue, steel gray, seafoam highlights, deep navy shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Walnut

Theme ID: `BoardThemeId.walnut`

Asset: `assets/chess/themes/walnut-study.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: walnut chess study arena backdrop
Scene/backdrop: refined walnut-paneled private study, dark wooden cabinets and
carved trim at edges, warm desk lamps, subtle chess-board geometry in a
polished walnut parquet floor
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: rich quiet evening study, elegant and focused
Color palette: dark walnut, leather brown, cream highlights, muted burgundy
shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Midnight

Theme ID: `BoardThemeId.midnight`

Asset: `assets/chess/themes/midnight-observatory.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: midnight chess observatory arena backdrop
Scene/backdrop: dark midnight observatory chess chamber, tall arched windows
with starry sky, subtle moonlight beams, polished dark floor with faint
chess-board geometry, quiet architectural details at edges
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and low-contrast for
app UI overlays, decorative detail toward edges
Lighting/mood: mysterious blue moonlit strategy atmosphere, premium desktop
game feel
Color palette: midnight navy, charcoal, soft silver-blue, small violet
highlights
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Jungle Canopy

Theme ID: `BoardThemeId.jungleCanopy`

Asset: `assets/chess/themes/jungle-arena.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: jungle chess arena backdrop
Scene/backdrop: lush jungle clearing with soft layered foliage, mossy stone
hints, subtle chess-board-like geometry integrated into the ground, distant
canopy light
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: warm filtered sunlight, premium strategy game atmosphere
Color palette: emerald greens, deep teal shadows, small amber highlights
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Coral Reef

Theme ID: `BoardThemeId.coralReef`

Asset: `assets/chess/themes/ocean-arena.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: ocean chess arena backdrop
Scene/backdrop: serene underwater-meets-coastal stone chess hall, blue water
glow, coral silhouettes at edges, faint wave caustics, polished slate floor
with subtle chess-board geometry
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center kept calm and lower-contrast
for app UI overlays, decorative detail toward edges
Lighting/mood: cool luminous ocean light, calm premium strategy atmosphere
Color palette: deep navy, aqua, slate blue, small pearl highlights
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Desert Sun

Theme ID: `BoardThemeId.desertSun`

Asset: `assets/chess/themes/desert-arena.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: desert chess arena backdrop
Scene/backdrop: vast sandstone chess courtyard at sunset, carved stone arches
at the edges, distant dunes, subtle chess-board geometry in the floor
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative detail toward edges
Lighting/mood: golden sunset, elegant ancient strategy arena
Color palette: warm sand, copper, muted amber, deep umber shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Frost Temple

Theme ID: `BoardThemeId.frostTemple`

Asset: `assets/chess/themes/frost-temple.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: frost temple chess arena backdrop
Scene/backdrop: crystalline ice temple chess hall, frosted pillars at edges,
distant snowy mountains, subtle chess-board geometry in polished ice floor
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative detail toward edges
Lighting/mood: crisp moonlit blue-white glow, quiet majestic strategy arena
Color palette: icy blue, pale cyan, white frost, deep blue shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Lava Forge

Theme ID: `BoardThemeId.lavaForge`

Asset: `assets/chess/themes/lava-forge.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: lava forge chess arena backdrop
Scene/backdrop: volcanic forge chess arena, basalt pillars at edges, glowing
lava channels, dark anvil-like stone floor with subtle chess-board geometry
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and darker for app UI
overlays, decorative glow toward edges
Lighting/mood: intense ember glow, dramatic but readable strategy arena
Color palette: charcoal black, deep red, molten orange, muted gold highlights
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Sakura Garden

Theme ID: `BoardThemeId.sakuraGarden`

Asset: `assets/chess/themes/sakura-garden.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: sakura garden chess arena backdrop
Scene/backdrop: tranquil Japanese-inspired garden chess terrace, soft cherry
blossom trees at edges, stone lantern silhouettes, wooden bridge hints, subtle
chess-board geometry in garden stone floor
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative detail toward edges
Lighting/mood: soft spring twilight, elegant peaceful strategy arena
Color palette: muted rose pink, moss green, warm stone, deep plum shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Neon City

Theme ID: `BoardThemeId.neonCity`

Asset: `assets/chess/themes/neon-city.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: neon city chess arena backdrop
Scene/backdrop: rainy neon rooftop chess arena in a futuristic city, reflective
dark floor with subtle chess-board geometry, cyberpunk skyline and light signs
only as abstract unreadable shapes at edges
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and darker for app UI
overlays, decorative neon detail toward edges
Lighting/mood: cinematic neon rain, sharp modern strategy atmosphere
Color palette: cyan, magenta, charcoal, small electric yellow highlights
Constraints: no readable text, no watermark, no logos, no UI mockup, no people,
no animals; background must remain usable behind a chessboard and panels
```

### Royal Marble

Theme ID: `BoardThemeId.royalMarble`

Asset: `assets/chess/themes/royal-marble.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: royal marble chess palace backdrop
Scene/backdrop: grand marble palace chess hall, white and charcoal marble floor
with subtle chess-board geometry, gold-trimmed columns at edges, velvet
shadows, distant arches
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative palace detail toward edges
Lighting/mood: refined royal daylight, luxurious premium strategy game
atmosphere
Color palette: ivory marble, charcoal veining, muted gold, deep burgundy
shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Autumn Academy

Theme ID: `BoardThemeId.autumnAcademy`

Asset: `assets/chess/themes/autumn-academy.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: autumn academy chess courtyard backdrop
Scene/backdrop: old academy courtyard in autumn, brick arches and library
windows at edges, maple leaves on stone, subtle chess-board geometry in the
courtyard paving
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative foliage toward edges
Lighting/mood: soft late afternoon, scholarly warm strategy atmosphere
Color palette: amber leaves, brick red, olive green, warm stone, deep brown
shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Crystal Cavern

Theme ID: `BoardThemeId.crystalCavern`

Asset: `assets/chess/themes/crystal-cavern.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: crystal cavern chess arena backdrop
Scene/backdrop: luminous underground crystal cavern chess arena, faceted quartz
formations at edges, reflective mineral floor with subtle chess-board geometry,
deep cave shadows
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative crystals toward edges
Lighting/mood: magical cool glow, focused premium strategy atmosphere
Color palette: violet, teal, icy white crystals, dark indigo shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

### Sky Citadel

Theme ID: `BoardThemeId.skyCitadel`

Asset: `assets/chess/themes/sky-citadel.png`

```text
Use case: stylized-concept
Asset type: Flutter desktop chess app themed background
Primary request: sky citadel chess arena backdrop
Scene/backdrop: floating cloud citadel chess arena, pale stone platform above
clouds with subtle chess-board geometry, airy columns at edges, distant golden
sunrise and soft sky
Subject: environment only, no characters, no chess pieces, no readable text
Style/medium: polished stylized digital illustration, desktop game UI
background, painterly but clean
Composition/framing: 16:9 wide landscape, center calm and lower-contrast for
app UI overlays, decorative architecture toward edges
Lighting/mood: bright serene heroic strategy atmosphere
Color palette: sky blue, white stone, warm gold, soft lavender shadows
Constraints: no text, no watermark, no logos, no UI mockup, no people, no
animals; background must remain usable behind a chessboard and panels
```

## Adding A New Theme

1. Generate a 16:9 scene image with the base template.
2. Save the final image under `assets/chess/themes/<theme-slug>.png`.
3. Add the theme ID to `BoardThemeId`.
4. Add English and Traditional Chinese labels in `BoardThemeId.localizedLabel`.
5. Add a `BoardThemeStyle` entry with board colors and `backdropAsset`.
6. Run `dart format lib/src/theme/board_theme.dart`.
7. Run `flutter analyze` and `flutter test`.
