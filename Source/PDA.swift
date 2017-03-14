import Foundation

/// A `Node` implementation for a Push-Down Automata.
public final class PDA<Reading, Marker>: BuildableNode {
  public typealias Input = Reading
  public typealias Meta = [Marker]

  public private(set) var terminal: Bool
  public private(set) var transitions: [Transition<PDA>]

  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: An array of transitions which connect this node to
  ///                          others within the automata.
  public init(terminal: Bool = false, transitions: [Transition<PDA>]) {
    self.terminal = terminal
    self.transitions = transitions
  }
  
  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: A listing of transitions which connect this node to
  ///                          others within the automata.
  public convenience init(terminal: Bool = false, transitions: Transition<PDA>...) {
    self.init(terminal: terminal, transitions: transitions)
  }

  /// Create a new node.
  /// - parameter terminal: Indicate whether or not this node determines the
  ///                       successful evaluation of the automata it belongs to.
  /// - parameter transitions: A transitions which connect this node to another within the automata.
  public convenience init(terminal: Bool = false, transition: Transition<PDA>) {
    self.init(terminal: terminal, transitions: transition)
  }

  public func add(transition: Transition<PDA>) {
    transitions.append(transition)
  }
}
