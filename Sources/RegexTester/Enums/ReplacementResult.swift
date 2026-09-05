//
//  ReplacementResult.swift
//  RegexTester
//
//  The outcome of `RegexTester.replace`: either the pattern failed to compile, or the
//  replacement succeeded and produced a new string.
//
//  Created by David Sherlock on 9/5/26.
//

import Foundation

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
