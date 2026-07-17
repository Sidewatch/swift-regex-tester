//
//  RegexTesterTests.swift
//  Tests for SwiftRegexTester
//
//  Created by David Sherlock on 7/18/26.
//

import XCTest
@testable import RegexTester

final class RegexTesterTests: XCTestCase {

    // MARK: - Numbered capture groups

    func testEmailPatternTwoMatchesWithGroups() {
        let input = "a@b.com x@y.io"
        let result = RegexTester.evaluate(pattern: #"(\w+)@(\w+)\.(\w+)"#, in: input)
        guard let matches = result.matches else { return XCTFail("expected matches, got \(result)") }
        XCTAssertEqual(matches.count, 2)

        XCTAssertEqual(matches[0].value, "a@b.com")
        XCTAssertEqual(matches[0].group(1)?.value, "a")
        XCTAssertEqual(matches[0].group(2)?.value, "b")
        XCTAssertEqual(matches[0].group(3)?.value, "com")

        XCTAssertEqual(matches[1].value, "x@y.io")
        XCTAssertEqual(matches[1].groups[0]?.value, "x")   // groups[0] == group(1)
        XCTAssertEqual(matches[1].groups[1]?.value, "y")
        XCTAssertEqual(matches[1].groups[2]?.value, "io")
    }

    // MARK: - Named capture groups

    func testNamedGroups() {
        let result = RegexTester.evaluate(pattern: #"(?<year>\d{4})-(?<month>\d{2})"#, in: "2026-07")
        guard let match = result.matches?.first else { return XCTFail("expected a match") }
        XCTAssertEqual(match.value, "2026-07")
        XCTAssertEqual(match.named["year"], "2026")
        XCTAssertEqual(match.named["month"], "07")
    }

    func testNamedGroupExtractionFromPattern() {
        XCTAssertEqual(RegexPattern.namedGroups(in: #"(?<year>\d{4})-(?<month>\d{2})"#),
                       ["year", "month"])
        // Lookbehind must NOT be mistaken for a named group.
        XCTAssertEqual(RegexPattern.namedGroups(in: #"(?<=x)(?<tail>\w+)"#), ["tail"])
        // Quote form.
        XCTAssertEqual(RegexPattern.namedGroups(in: #"(?'first'\w+)"#), ["first"])
    }

    // MARK: - Options

    func testCaseInsensitive() {
        XCTAssertTrue(RegexTester.evaluate(pattern: "hello", in: "HELLO").matches?.isEmpty ?? true)
        let result = RegexTester.evaluate(pattern: "hello", in: "HELLO", options: [.caseInsensitive])
        XCTAssertEqual(result.matches?.count, 1)
        XCTAssertEqual(result.matches?.first?.value, "HELLO")
    }

    func testAnchorsMatchLines() {
        let withOption = RegexTester.evaluate(pattern: #"^\w+"#, in: "foo\nbar",
                                              options: [.anchorsMatchLines])
        XCTAssertEqual(withOption.matches?.map { $0.value }, ["foo", "bar"])

        let withoutOption = RegexTester.evaluate(pattern: #"^\w+"#, in: "foo\nbar")
        XCTAssertEqual(withoutOption.matches?.map { $0.value }, ["foo"])
    }

    // MARK: - Errors & empty results

    func testInvalidPatternReturnsError() {
        let result = RegexTester.evaluate(pattern: "(", in: "anything")
        guard let error = result.error else { return XCTFail("expected a compile error") }
        XCTAssertFalse(error.message.isEmpty)
        XCTAssertNil(result.matches)
    }

    func testNoMatchIsEmptyNotError() {
        let result = RegexTester.evaluate(pattern: "xyz", in: "abc")
        XCTAssertEqual(result.matches, [])
        XCTAssertNil(result.error)
    }

    func testEmptyPatternAndEmptyInputDoNotCrash() {
        // An empty pattern must be handled as a value (matches or a compile error), never a crash.
        let empty = RegexTester.evaluate(pattern: "", in: "ab")
        XCTAssertTrue(empty.matches != nil || empty.error != nil)
        // A valid pattern against empty input is an empty match list, not an error.
        XCTAssertEqual(RegexTester.evaluate(pattern: #"\d+"#, in: "").matches, [])
    }

    func testNonParticipatingGroupIsNil() {
        let result = RegexTester.evaluate(pattern: "(a)|(b)", in: "a")
        guard let match = result.matches?.first else { return XCTFail("expected a match") }
        XCTAssertEqual(match.value, "a")
        XCTAssertEqual(match.group(1)?.value, "a")
        XCTAssertNil(match.group(2))       // second alternative didn't participate
    }

    // MARK: - Replacement

    func testReplaceNumericTemplate() {
        let result = RegexTester.replace(pattern: #"(\d+)"#, in: "a1b22", template: "[$1]")
        XCTAssertEqual(result.string, "a[1]b[22]")
    }

    func testReplaceNamedTemplate() {
        let result = RegexTester.replace(pattern: #"(?<num>\d+)"#, in: "a1b22", template: "<${num}>")
        XCTAssertEqual(result.string, "a<1>b<22>")
    }

    func testReplaceInvalidPatternReturnsError() {
        let result = RegexTester.replace(pattern: "(", in: "abc", template: "x")
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.string)
    }

    // MARK: - Range fidelity

    func testRangesIndexOriginalString() {
        let input = "a@b.com x@y.io"
        let result = RegexTester.evaluate(pattern: #"(\w+)@(\w+)\.(\w+)"#, in: input)
        guard let matches = result.matches else { return XCTFail("expected matches") }
        for match in matches {
            // The full-match range round-trips to the matched substring.
            XCTAssertEqual(String(input[match.range]), match.value)
            // Every participating group's range does too.
            for group in match.groups.compactMap({ $0 }) {
                XCTAssertEqual(String(input[group.range]), group.value)
            }
        }
    }

    func testUTF16OffsetsWithNonBMPCharacters() {
        // "😀" is 2 UTF-16 code units; the match after it starts at offset 2.
        let input = "😀ok"
        let result = RegexTester.evaluate(pattern: "ok", in: input)
        guard let match = result.matches?.first else { return XCTFail("expected a match") }
        XCTAssertEqual(match.value, "ok")
        XCTAssertEqual(match.offset, 2)      // UTF-16 code units, not characters
        XCTAssertEqual(match.length, 2)
        XCTAssertEqual(String(input[match.range]), "ok")   // range still indexes correctly
    }
}
