import Foundation

/// A Node implementation for a Non-Deterministic Finite Automata.
public final class NFA<Reading>: Node {
  public typealias Input = Reading

  /// NFAs don't require any metadata context for their evaluation.
  public typealias Meta = ()

  public var terminal: Bool
  public var transitions: [Transition<NFA>]

  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: An array of transitions which connect this node to
  ///                          others within the automata.
  public init(terminal: Bool = false, transitions: [Transition<NFA>]) {
    self.terminal = terminal
    self.transitions = transitions
  }

  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: A listing of transitions which connect this node to
  ///                          others within the automata.
  public convenience init(terminal: Bool = false, transitions: Transition<NFA>...) {
    self.init(terminal: terminal, transitions: transitions)
  }

  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: A transitions which connect this node to another within the automata.
  public convenience init(terminal: Bool = false, transition: Transition<NFA>) {
    self.init(terminal: terminal, transitions: transition)
  }
}
