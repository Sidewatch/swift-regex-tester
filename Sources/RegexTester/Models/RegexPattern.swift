//
//  RegexPattern.swift
//  SwiftRegexTester
//
//  Lightweight pattern scanning: enumerate capture groups and their names without a regex.
//
//  Created by David Sherlock on 7/18/26.
//

import Foundation

/// Static analysis of a pattern string. `NSTextCheckingResult.range(withName:)` needs the
/// caller to supply group names, and template replacement needs a name→index map — both of
/// which mean reading the names straight out of the pattern. This scanner walks the pattern
/// once, honouring escapes and character classes, and reports every capturing group in order
/// with its optional name. It never compiles or executes the regex.
public enum RegexPattern {

    /// A capturing group discovered by scanning the pattern.
    struct CaptureGroup {
        /// The group's 1-based index, counting only capturing groups in pattern order.
        let index: Int
        /// The group's name for `(?<name>…)` / `(?'name'…)` / `(?P<name>…)`, else `nil`.
        let name: String?
    }

    /// The names of all named capture groups in the pattern, in order of appearance
    /// (`(?<name>…)`, `(?'name'…)`, and `(?P<name>…)` forms). Duplicates are possible only
    /// if the pattern itself repeats a name.
    public static func namedGroups(in pattern: String) -> [String] {
        captureGroups(in: pattern).compactMap { $0.name }
    }

    /// Map each named group to its 1-based capture index (later duplicates win).
    static func nameToIndex(in pattern: String) -> [String: Int] {
        var map: [String: Int] = [:]
        for group in captureGroups(in: pattern) {
            if let name = group.name { map[name] = group.index }
        }
        return map
    }

    /// Every capturing group in the pattern, in order, with its 1-based index and optional
    /// name. Non-capturing constructs — `(?:…)`, lookaround `(?=…)`/`(?!…)`/`(?<=…)`/`(?<!…)`,
    /// atomic `(?>…)`, inline flags `(?i)`, comments `(?#…)` — are skipped, as are parens
    /// that are escaped or sit inside a `[…]` character class.
    static func captureGroups(in pattern: String) -> [CaptureGroup] {
        let chars = Array(pattern)
        let count = chars.count
        var groups: [CaptureGroup] = []
        var groupIndex = 0
        var inClass = false
        var i = 0

        while i < count {
            let c = chars[i]

            // An escape consumes the next character wherever it appears (incl. in classes).
            if c == "\\" {
                i += 2
                continue
            }

            if inClass {
                if c == "]" { inClass = false }
                i += 1
                continue
            }

            if c == "[" {
                inClass = true
                i += 1
                continue
            }

            if c == "(" {
                // `(?…` is some special construct; a bare `(` is a plain capturing group.
                if i + 1 < count, chars[i + 1] == "?" {
                    let third = i + 2 < count ? chars[i + 2] : " "
                    if third == "<" {
                        let fourth = i + 3 < count ? chars[i + 3] : " "
                        if fourth == "=" || fourth == "!" {
                            i += 1                              // lookbehind — non-capturing
                        } else {
                            let (name, next) = readName(chars, from: i + 3, terminator: ">")
                            groupIndex += 1
                            groups.append(CaptureGroup(index: groupIndex, name: name))
                            i = next
                        }
                    } else if third == "'" {
                        let (name, next) = readName(chars, from: i + 3, terminator: "'")
                        groupIndex += 1
                        groups.append(CaptureGroup(index: groupIndex, name: name))
                        i = next
                    } else if third == "P", i + 3 < count, chars[i + 3] == "<" {
                        let (name, next) = readName(chars, from: i + 4, terminator: ">")
                        groupIndex += 1
                        groups.append(CaptureGroup(index: groupIndex, name: name))
                        i = next
                    } else {
                        i += 1                                  // (?:…), (?=…), (?i), (?#…), …
                    }
                } else {
                    groupIndex += 1
                    groups.append(CaptureGroup(index: groupIndex, name: nil))
                    i += 1
                }
                continue
            }

            i += 1
        }

        return groups
    }

    /// Read a group name starting at `start` up to (not including) `terminator`, returning
    /// the name and the index just past the terminator.
    private static func readName(_ chars: [Character], from start: Int,
                                 terminator: Character) -> (name: String, next: Int) {
        var name = ""
        var i = start
        while i < chars.count, chars[i] != terminator {
            name.append(chars[i])
            i += 1
        }
        return (name, min(i + 1, chars.count))   // skip the terminator
    }

    /// Rewrite `${name}` references in a replacement `template` into the `$<index>` form
    /// `NSRegularExpression` understands, using the named groups declared in `pattern`.
    /// References to unknown names, and all other characters (including escaped `\$`), are
    /// left untouched.
    static func expandNamedReferences(in template: String, pattern: String) -> String {
        guard template.contains("${") else { return template }
        let map = nameToIndex(in: pattern)
        guard !map.isEmpty else { return template }

        let chars = Array(template)
        let count = chars.count
        var out = ""
        var i = 0

        while i < count {
            let c = chars[i]

            // Preserve escaped sequences (`\$`, `\\`, …) verbatim.
            if c == "\\", i + 1 < count {
                out.append(c)
                out.append(chars[i + 1])
                i += 2
                continue
            }

            if c == "$", i + 1 < count, chars[i + 1] == "{" {
                var j = i + 2
                var name = ""
                while j < count, chars[j] != "}" {
                    name.append(chars[j])
                    j += 1
                }
                if j < count, chars[j] == "}", let index = map[name] {
                    out += "$\(index)"
                    i = j + 1
                    continue
                }
            }

            out.append(c)
            i += 1
        }

        return out
    }
}
