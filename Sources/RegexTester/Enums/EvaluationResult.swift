//
//  EvaluationResult.swift
//  RegexTester
//
//  The outcome of `RegexTester.evaluate`: either the pattern failed to compile, or it compiled
//  and produced zero or more matches.
//
//  Created by David Sherlock on 9/5/26.
//

import Foundation

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
