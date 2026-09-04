# Swift Regex Tester

A dependency-free, read-only engine for a regex-tester tool panel: evaluate a pattern against a test string and get back structured matches — full-match and capture-group ranges, named groups, and template replacement. Pure Foundation (`NSRegularExpression`), zero dependencies, never mutates its input, and **never throws** — compile errors come back as values so a UI can show them inline.

- Module `RegexTester` in `Sources/RegexTester`; tests in `Tests`; `swift test` is the whole check.
- Swift 6 language mode, tools 6.0, macOS 14+, no dependencies unless the README says so.
- Part of the Sidewatch package family; every package follows the same layout and PR rules.

## Module map

- `Core/` — the engine: RegexTester
- `Errors/` — every Error type, one per file: RegexError
- `Models/` — value types — the shape of a thing, nothing else: RegexOptions, RegexPattern, RegexResult

## Rules

Read `CONTRIBUTING.md` before changing anything: it is the layout and PR rulebook for this package.
