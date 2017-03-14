import Foundation

/// A state machine which is a function over a given input type.
///
/// This data structure can be used to represent a "language" of
/// combinations of the given input type's instances.
public struct Automata<Node: Reggie.Node> {
  public typealias Input = Node.Input
  public typealias Meta = Node.Meta

  /// A pairing of nodes with their corresponding metadata.
  var states: [(Node, Meta)]

  /// Indicate whether or not the automata is in a successfully terminating position.
  /// - returns: `true` when any of the nodes within this automata's current states are terminal.
  public var isPassing: Bool {
    return states.reduce(false) { $0 || $1.0.terminal }
  }

  /// Create a new automata using the specified initial root node and metadata.
  /// - parameter node: The initial node with which to start evaluating input.
  /// - parameter meta: Any initial metadata value that should accompany evaluated nodes.
  public init(root node: Node, _ meta: Meta) {
    states = [(node, meta)]
  }

  /// Create a new automata using the specified current states.
  /// - parameter states: A pairing of nodes with their corresponding metadata.
  init?(states: [(Node, Meta)]) {
    guard states.isEmpty == false else { return nil }
    self.states = states
  }

  /// Evaluate the automata with the given input.
  /// - parameter input: A unit of input data which can allow the automata's
  ///                    internal state machine to advance by one transition.
  /// - returns: An automata with an internal state machine that has advanced according
  ///            to the given input. Otherwise, if the input does not result in the
  ///            successful transition from one node to another, `nil` is returned.
  public func advance(with input: Input) -> Automata? {
    let nextStates = states.flatMap { state -> [(Node, Meta)] in
      let (node, meta) = state
      return node.transitions.flatMap { $0.traverse(with:input, meta) }
    }
    return Automata(states: nextStates)
  }

  /// Determine whether the language described by this automata contains the given input.
  /// - parameter input: A sequence of input values which determine the progression of the automata.
  /// - returns: `true` if the automata's state machine lands on a terminal node when the automata's
  ///            state machine has advanced over every input element within the given sequence.
  ///            This means that the given input does indeed belong within the language described
  ///            by the automata.
  public func contains<S: Sequence>(input: S) -> Bool where S.Iterator.Element == Input {
    let result = input.reduce(self) { automata, element in
      return automata?.advance(with: element)
    }
    return result.map { $0.isPassing } ?? false
  }
}

extension Automata where Node.Meta == () {
  /// Create a new automata using the specified initial root node
  /// which doesn't require metadata to operate.
  /// parameter node: The initial node with which to start evaluating input.
  public init(root node: Node) {
    self.init(root: node, ())
  }
}
