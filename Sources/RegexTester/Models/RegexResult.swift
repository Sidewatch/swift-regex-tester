//
//  RegexResult.swift
//  SwiftRegexTester
//
//  The value types a regex evaluation returns: matches, capture groups, and errors.
//
//  Created by David Sherlock on 7/18/26.
//

import Foundation
/// One capture group's slice of the input.
///
/// `range` indexes the *original* `String` passed to `evaluate`, so
/// `String(input[group.range]) == group.value`. `offset` and `length` describe the same
/// span in **UTF-16 code units** (the unit `NSRegularExpression` reports), measured from
/// the start of the string — handy when a view highlights over UTF-16-based storage.
public struct Group: Equatable {

    /// The text this group captured.
    public let value: String

    /// The group's range within the original string (use it to subscript the input).
    public let range: Range<String.Index>

    /// The group's start, in UTF-16 code units from the start of the string.
    public let offset: Int

    /// The group's length, in UTF-16 code units.
    public let length: Int

    /// Create a capture group slice.
    public init(value: String, range: Range<String.Index>, offset: Int, length: Int) {
        self.value = value
        self.range = range
        self.offset = offset
        self.length = length
    }
}

/// A single whole-pattern match, plus its capture groups.
///
/// The match itself is capture group 0: `value`/`range`/`offset`/`length` describe the
/// full match (see `Group` for the offset/length units — UTF-16 code units). `groups`
/// holds the numbered sub-groups 1…n in order; `named` maps `(?<name>…)` group names to
/// the text they captured.
public struct Match: Equatable {

    /// The full matched substring.
    public let value: String

    /// The full match's range within the original string (`String(input[range]) == value`).
    public let range: Range<String.Index>

    /// The full match's start, in UTF-16 code units from the start of the string.
    public let offset: Int

    /// The full match's length, in UTF-16 code units.
    public let length: Int

    /// Numbered capture groups 1…n, in pattern order. An element is `nil` when that group
    /// did not participate in the match (e.g. an unmatched alternative `(a)|(b)`).
    public let groups: [Group?]

    /// Named capture groups: name → captured text, for the named groups that participated.
    public let named: [String: String]

    /// Create a match.
    public init(value: String, range: Range<String.Index>, offset: Int, length: Int,
                groups: [Group?], named: [String: String]) {
        self.value = value
        self.range = range
        self.offset = offset
        self.length = length
        self.groups = groups
        self.named = named
    }

    /// The capture group at 1-based `index` (group 1 is the first `( … )`), or `nil` when
    /// the index is out of range or that group didn't participate.
    public func group(_ index: Int) -> Group? {
        guard index >= 1, index <= groups.count else { return nil }
        return groups[index - 1]
    }
}

/// The outcome of `RegexTester.evaluate`: either the pattern failed to compile, or it
/// compiled and produced zero or more matches. A valid pattern with no matches is
/// `.matches([])`, *not* an error.
public enum EvaluationResult: Equatable {

    /// The pattern could not be compiled.
    case error(RegexError)

    /// The pattern compiled; these are its matches (possibly empty).
    case matches([Match])

    /// The matches, or `nil` if the pattern failed to compile.
    public var matches: [Match]? {
        if case let .matches(m) = self { return m }
        return nil
    }

    /// The compile error, or `nil` if the pattern compiled.
    public var error: RegexError? {
        if case let .error(e) = self { return e }
        return nil
    }
}

/// The outcome of `RegexTester.replace`: either the pattern failed to compile, or the
/// replacement succeeded and produced a new string.
public enum ReplacementResult: Equatable {

    /// The pattern could not be compiled.
    case error(RegexError)

    /// The input with every match replaced by the expanded template.
    case replaced(String)

    /// The resulting string, or `nil` if the pattern failed to compile.
    public var string: String? {
        if case let .replaced(s) = self { return s }
        return nil
    }

    /// The compile error, or `nil` if the pattern compiled.
    public var error: RegexError? {
        if case let .error(e) = self { return e }
        return nil
    }
}
