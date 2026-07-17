//
//  RegexTester.swift
//  SwiftRegexTester
//
//  Evaluate a pattern against a string (or replace with a template) and return structured,
//  crash-free results — the read-only logic behind a regex-tester panel.
//
//  Created by David Sherlock on 7/18/26.
//

import Foundation

/// The public entry point: compile a pattern and run it against a test string, returning
/// structured matches (or a compile error) as values. Nothing here throws, and no input is
/// mutated. `NSRegularExpression` works in UTF-16, so every reported `NSRange` is converted
/// to a `String.Index` range against the *original* string — the ranges index it directly —
/// while `offset`/`length` expose the same spans in UTF-16 code units.
public enum RegexTester {

    /// Compile `pattern` and find every match in `string`.
    ///
    /// Returns `.error` (with a message) when the pattern is invalid, or `.matches` — which
    /// is empty, never an error, when a valid pattern simply doesn't match. Each `Match`
    /// carries its full-match slice, numbered capture groups (1…n, `nil` where a group
    /// didn't participate), and a name→text map for `(?<name>…)` groups.
    ///
    /// - Parameters:
    ///   - pattern: The regular expression source.
    ///   - string: The text to search.
    ///   - options: Compile-time flags (see `RegexOptions`).
    /// - Returns: An `EvaluationResult`.
    public static func evaluate(pattern: String, in string: String,
                                options: RegexOptions = []) -> EvaluationResult {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options.nsOptions)
        } catch {
            return .error(RegexError(error.localizedDescription))
        }

        let names = RegexPattern.namedGroups(in: pattern)
        let fullRange = NSRange(string.startIndex..., in: string)
        let results = regex.matches(in: string, options: [], range: fullRange)
        return .matches(results.map { match($0, in: string, names: names) })
    }

    /// Compile `pattern` and replace every match in `string` with `template`.
    ///
    /// The template uses `NSRegularExpression` semantics — `$0` is the whole match, `$1`…`$n`
    /// are numbered groups, and `\$` is a literal dollar. As a convenience, `${name}`
    /// references to named groups are expanded to their numeric form before replacement.
    /// Returns `.error` when the pattern is invalid.
    ///
    /// - Parameters:
    ///   - pattern: The regular expression source.
    ///   - string: The text to transform.
    ///   - template: The replacement template.
    ///   - options: Compile-time flags (see `RegexOptions`).
    /// - Returns: A `ReplacementResult`.
    public static func replace(pattern: String, in string: String, template: String,
                               options: RegexOptions = []) -> ReplacementResult {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options.nsOptions)
        } catch {
            return .error(RegexError(error.localizedDescription))
        }

        let expanded = RegexPattern.expandNamedReferences(in: template, pattern: pattern)
        let fullRange = NSRange(string.startIndex..., in: string)
        let output = regex.stringByReplacingMatches(in: string, options: [],
                                                    range: fullRange, withTemplate: expanded)
        return .replaced(output)
    }

    // MARK: - Building results

    /// Assemble a `Match` from one `NSTextCheckingResult` against `string`.
    private static func match(_ result: NSTextCheckingResult, in string: String,
                              names: [String]) -> Match {
        let full = group(from: result.range, in: string)

        // Numbered groups 1…n (range 0 is the full match, handled above).
        var groups: [Group?] = []
        if result.numberOfRanges > 1 {
            groups.reserveCapacity(result.numberOfRanges - 1)
            for index in 1..<result.numberOfRanges {
                groups.append(group(from: result.range(at: index), in: string))
            }
        }

        // Named groups — query each name the pattern declared; skip non-participants.
        var named: [String: String] = [:]
        for name in names {
            let nsRange = result.range(withName: name)
            if let captured = group(from: nsRange, in: string) {
                named[name] = captured.value
            }
        }

        return Match(value: full?.value ?? "",
                     range: full?.range ?? string.startIndex..<string.startIndex,
                     offset: full?.offset ?? result.range.location,
                     length: full?.length ?? 0,
                     groups: groups,
                     named: named)
    }

    /// Convert an `NSRange` into a `Group`, or `nil` when the range didn't participate
    /// (`NSNotFound`) or can't be mapped back onto `string`.
    private static func group(from nsRange: NSRange, in string: String) -> Group? {
        guard nsRange.location != NSNotFound,
              let range = Range(nsRange, in: string) else { return nil }
        return Group(value: String(string[range]), range: range,
                     offset: nsRange.location, length: nsRange.length)
    }
}
