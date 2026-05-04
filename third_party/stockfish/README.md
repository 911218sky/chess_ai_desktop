# Stockfish Runtime Bundle

This directory is reserved for the locally downloaded Stockfish Windows binary
used by packaging workflows.

- Run `tools/download_stockfish.ps1` to place `stockfish.exe` under
  `third_party/stockfish/windows/`
- The downloaded engine binary and copied license files are ignored by Git
- GitHub Actions downloads the same engine during release packaging
