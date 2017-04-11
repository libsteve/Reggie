import Foundation

/// A generator which emits values that belong to a given automata's language.
public struct Lexer<Input> {
  /// - note: This is `internal` for testing only.
  internal var iterator: AnyIterator<Input>

  /// Create a new lexer which reads from the given iterator.
  public init<Iterator: IteratorProtocol>(reading iterator: Iterator)
    where Input == Iterator.Element {
      self.iterator = AnyIterator(iterator)
  }

  /// Create a new lexer which reads from the given sequence.
  public init<S: Sequence>(reading sequence: S)
    where Input == S.Iterator.Element {
      self.iterator = AnyIterator(sequence.makeIterator())
  }

  /// Generate the next match for the given automata.
  /// - parameter automata: The automata against which this lexer's input should match.
  /// - returns: `nil` if no match is found. Otherwise, the matching subsequence is returned.
  /// - note: If a match isn't found for an automata, it might match another. The internal iterator
  ///         will only advance when a match is found.
  public mutating func next<Meta>(matching automata: Automata<Input, Meta>) -> [Input]? {
      var automata = automata,
          consumed: [Input] = [],
          passingInput: [Input]? = nil

      outerLoop: while let unit = iterator.next() {
        guard let advanced = automata.advance(with: unit) else {
          guard let passing = passingInput else {
            consumed.append(unit)
            break outerLoop
          }
          self.iterator = AnyIterator(emitting: [unit], before: iterator)
          return passing
        }
        consumed.append(unit)
        if advanced.isPassing { passingInput = consumed }
        automata = advanced
      }

      guard let passing = passingInput else {
        iterator = AnyIterator(emitting: consumed, before: iterator)
        return nil
      }
      let unread = consumed[passing.endIndex..<consumed.endIndex]
      iterator = AnyIterator(emitting: unread, before: iterator)
      return passing
  }
}
