# Chess AI Desktop

Windows-first Flutter desktop project for a local Stockfish chess opponent with
optional LLM banter, hint explanations, and post-game recaps.

## Status

- Flutter desktop scaffold created
- Windows desktop enabled
- Portable settings persistence enabled through local `settings.json`
- Windows release packaging and GitHub Actions workflows included
- Current UI guidance tracked in [docs/ui-style-guide.md](docs/ui-style-guide.md)

## Local Commands

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```

## What Does Not Go Into Git

The repository intentionally does not track generated output or downloaded local
runtime files:

- `build/`
- `.dart_tool/`
- `artifacts/`
- `windows/flutter/ephemeral/`
- `settings.json`
- `third_party/stockfish/windows/stockfish.exe`

That keeps the repository clean and avoids GitHub's 100 MB single-file limit.

## Download Stockfish For Packaging

GitHub cannot store the bundled `stockfish.exe` that was previously kept in the
repo because the file is larger than 100 MB. Download it only when you need a
local packaged build:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\download_stockfish.ps1
```

The script downloads the official Windows x64 Stockfish release into:

```text
third_party\stockfish\windows\stockfish.exe
```

The file stays local and is ignored by Git. During development, if the bundled
binary is missing, the app can still fall back to a `stockfish` executable on
`PATH`.

### Environment Variables

These variables override the defaults used by the download and release scripts:

- `CHESS_AI_DESKTOP_STOCKFISH_RELEASE_TAG`
- `CHESS_AI_DESKTOP_STOCKFISH_ASSET_NAME`
- `CHESS_AI_DESKTOP_STOCKFISH_DESTINATION_PATH`
- `CHESS_AI_DESKTOP_APP_PUBLISHER`

## Packaging Notes

- Windows app icon source: `windows/runner/resources/app_icon.ico`
- The Windows executable icon is wired through `windows/runner/Runner.rc`
- Runtime settings are stored as `settings.json` beside the packaged `.exe`
- The Windows installer defaults to a per-user writable directory so the app
  can still persist `settings.json` beside the installed executable

Local release build:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\download_stockfish.ps1
flutter build windows --release
```

Installer packaging uses:

```text
packaging/windows/chess_ai_desktop.iss
```

## GitHub Actions

- `.github/workflows/ci.yml`
  - Runs formatting, `flutter analyze`, and `flutter test`
- `.github/workflows/release.yml`
  - Builds the Windows release on tags like `v1.0.0`
  - Downloads Stockfish during the workflow
  - Produces both a portable zip and a Windows installer
  - Publishes the build artifacts to a GitHub Release

## Clean Removal

To fully remove the app and its local data on Windows:

1. Close the app if it is running.
2. Delete the persisted settings file beside the packaged executable:

```powershell
Remove-Item ".\settings.json" -Force
```

This removes the local `settings.json` file stored under:

```text
<packaged-app-folder>\settings.json
```

3. Delete local build output from the repo:

```powershell
Remove-Item ".\build" -Recurse -Force
```

4. If you also want to clear Flutter-generated local metadata for this checkout:

```powershell
flutter clean
```

5. If you no longer want the downloaded Dart and Flutter package artifacts for
this project, refresh dependencies again later with:

```powershell
flutter pub get
```

## Notes

- Android warnings from `flutter doctor` are currently irrelevant for this
  Windows-only first phase
- Chess piece SVG assets are stored under `assets/chess/pieces/cburnett/`
- Keep the bundled asset license notice when packaging the app
- Stockfish release binaries are downloaded from the official Stockfish release
  feed during packaging and are not committed to this repository
