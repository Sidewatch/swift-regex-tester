# Swift Regex Tester

A dependency-free, read-only engine for a regex-tester tool panel: evaluate a pattern against a test string and get back structured matches — full-match and capture-group ranges, named groups, and template replacement. Pure Foundation (`NSRegularExpression`), zero dependencies, never mutates its input, and **never throws** — compile errors come back as values so a UI can show them inline.

## Features

- 🎯 **Structured matches** — `RegexTester.evaluate(pattern:in:options:)` returns every match with its full-match substring, numbered capture groups (1…n, `nil` where a group didn't participate), and named groups as `[name: text]`
- 🧭 **Usable ranges** — each match/group carries a `Range<String.Index>` that indexes the *original* string (`String(input[match.range]) == match.value`), plus `offset`/`length` in **UTF-16 code units** for highlighting over UTF-16-based storage
- 🏷 **Named groups** — `(?<name>…)`, `(?'name'…)`, and `(?P<name>…)` are parsed straight from the pattern (lookbehind `(?<=…)`/`(?<!…)` is not mistaken for one)
- 🔁 **Replacement** — `RegexTester.replace(pattern:in:template:options:)` with `NSRegularExpression` template semantics (`$0`, `$1`…`$n`), plus `${name}` convenience references expanded to their numeric form
- 🎛 **Options** — `caseInsensitive`, `dotMatchesLineSeparators`, `anchorsMatchLines` (multiline `^`/`$`), `allowCommentsAndWhitespace` (extended), `ignoreMetacharacters`, as an `OptionSet`
- 🛡 **Crash-free** — empty pattern, empty input, and no-match are all safe; a valid pattern that doesn't match returns `.matches([])`, not an error
- 🪶 **Zero dependencies** — Foundation only
- 🍎 **Cross-platform** — iOS, macOS, tvOS, watchOS, visionOS

## Requirements

- macOS 14+ (Foundation only; other Apple platforms at SwiftPM's default minimums)
- Swift 6.0+ (Swift 6 language mode)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Sidewatch/swift-regex-tester.git", from: "1.0.0")
]
```

## Usage

```swift
import RegexTester

// Evaluate
switch RegexTester.evaluate(pattern: #"(\w+)@(\w+)\.(\w+)"#, in: "a@b.com x@y.io") {
case .error(let error):
    print("bad pattern:", error.message)
case .matches(let matches):
    for match in matches {
        print(match.value)                 // "a@b.com"
        print(match.group(1)?.value ?? "")  // "a"
        print(match.offset, match.length)   // UTF-16 offset + length
    }
}

// Named groups
let dated = RegexTester.evaluate(pattern: #"(?<year>\d{4})-(?<month>\d{2})"#, in: "2026-07")
print(dated.matches?.first?.named ?? [:])   // ["year": "2026", "month": "07"]

// Options
RegexTester.evaluate(pattern: "hello", in: "HELLO", options: [.caseInsensitive])

// Replace ($1, ${name})
RegexTester.replace(pattern: #"(\d+)"#, in: "a1b22", template: "[$1]").string  // "a[1]b[22]"
RegexTester.replace(pattern: #"(?<n>\d+)"#, in: "a1b22", template: "<${n}>").string  // "a<1>b<22>"
```

## For agents

Read `CONTRIBUTING.md` first: the folder layout and the PR rules. `swift test` is the whole
check, and a new test must fail before the change it covers. `CLAUDE.md` / `AGENTS.md` carry a
module map.

## License

MIT © 2026 David Sherlock (ArrayPress)
