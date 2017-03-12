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
