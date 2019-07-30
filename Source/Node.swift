import Foundation

/// A specific identifiable state within an automata.
public struct State {
  fileprivate let id: UUID = UUID()

  /// Create a state node for an automata.
  public init() {}
}

extension State: Hashable {
  public static func ==(lhs: State, rhs: State) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    return hasher.combine(id)
  }
}

/// A type to denote whether or not a node represents the end
/// of a passing "word" within an automata's "language".
public enum Termination {
  /// Denotes a possible end of a match within the automata.
  case terminating

  /// Denotes a regular, nothing-special node within the automata.
  case nonterminating
}
