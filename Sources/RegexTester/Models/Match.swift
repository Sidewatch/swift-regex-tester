//
//  Match.swift
//  RegexTester
//

import Foundation

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
