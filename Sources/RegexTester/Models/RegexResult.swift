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
