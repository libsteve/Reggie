import Foundation

/// A specific state within an automata.
/// - note: It is probably for the best for implementers of this protocol to be reference types.
public protocol Node {
  /// The type of data that the automata reads to advance the state machine between nodes.
  associatedtype Input

  /// Any data structure which can be used to assist the evaluation of the teansition function
  /// between nodes during the execution of the automata's state machine.
  associatedtype Meta

  /// If the state machine lands on this node at the end of receiving input, this value signifies
  /// the successful evaluation of the automata over the given input.
  var terminal: Bool { get }

  /// A list of transitions from this node to other nodes over some transition function.
  var transitions: [Transition<Self>] { get }
}

/// A state within an automata to which new transitions may be added.
public protocol BuildableNode: Node {
  /// Add a transition to a node over some condition.
  /// - parameter transition: The transition which should be added to this node.
  mutating func add(transition: Transition<Self>)
}

extension BuildableNode {
  /// Add a transition to the given node.
  /// - parameter node: The node to which the automata may be transitioned.
  /// - parameter condition: A function over a unit of input and some metadata which determines
  ///                        whether or not the automata should follow this transition.
  public mutating func transition(to node: Self,
                                  over condition: @escaping (Input, Meta) -> (Bool, Meta)) {
    self.add(transition: Transition(to: node, when: condition))
  }
}

extension BuildableNode where Meta == () {
  /// Add a transition to the given node.
  /// - parameter node: The node to which the automata may be transitioned.
  /// - parameter condition: A function over a unit of input which determines whether
  ///                        or not the automata should follow this transition.
  public mutating func transition(to node: Self, over condition: @escaping (Input) -> Bool) {
    self.add(transition: Transition(to: node, when: condition))
  }
}
