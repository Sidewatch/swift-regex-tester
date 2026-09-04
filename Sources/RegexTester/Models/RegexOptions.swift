//
//  RegexOptions.swift
//  SwiftRegexTester
//
//  Compile-time flags for a pattern, mapped 1:1 onto NSRegularExpression.Options.
//
//  Created by David Sherlock on 7/18/26.
//

import Foundation

/// The set of pattern flags a regex-tester panel exposes as checkboxes. Each maps
/// directly to an `NSRegularExpression.Options` case; combine them with set syntax
/// (`[.caseInsensitive, .anchorsMatchLines]`).
public struct RegexOptions: OptionSet, Sendable {

    /// The raw bit field backing the option set.
    public let rawValue: Int

    /// Create an option set from its raw bit field.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// Match letters case-insensitively (`NSRegularExpression.Options.caseInsensitive`).
    public static let caseInsensitive = RegexOptions(rawValue: 1 << 0)

    /// Allow `.` to match line separators too (`dotMatchesLineSeparators`, i.e. "dotall").
    public static let dotMatchesLineSeparators = RegexOptions(rawValue: 1 << 1)

    /// Make `^` and `$` match at the start/end of every line rather than the whole
    /// string (`anchorsMatchLines`, i.e. "multiline").
    public static let anchorsMatchLines = RegexOptions(rawValue: 1 << 2)

    /// Ignore unescaped whitespace and allow `#` comments in the pattern
    /// (`allowCommentsAndWhitespace`, i.e. "extended"/"verbose").
    public static let allowCommentsAndWhitespace = RegexOptions(rawValue: 1 << 3)

    /// Treat the entire pattern as a literal string, with no metacharacters
    /// (`ignoreMetacharacters`).
    public static let ignoreMetacharacters = RegexOptions(rawValue: 1 << 4)

    /// The equivalent `NSRegularExpression.Options` for these flags.
    var nsOptions: NSRegularExpression.Options {
        var options: NSRegularExpression.Options = []
        if contains(.caseInsensitive) { options.insert(.caseInsensitive) }
        if contains(.dotMatchesLineSeparators) { options.insert(.dotMatchesLineSeparators) }
        if contains(.anchorsMatchLines) { options.insert(.anchorsMatchLines) }
        if contains(.allowCommentsAndWhitespace) { options.insert(.allowCommentsAndWhitespace) }
        if contains(.ignoreMetacharacters) { options.insert(.ignoreMetacharacters) }
        return options
    }
}
