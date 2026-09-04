import Foundation

/// A pattern that failed to compile. Errors are returned as values — the public API
/// never throws — so a panel can render `message` next to the offending pattern.
public struct RegexError: Equatable {

    /// A human-readable description of why the pattern is invalid (from the underlying
    /// `NSRegularExpression` compile error).
    public let message: String

    /// Wrap a compile-error message.
    public init(_ message: String) { self.message = message }
}
