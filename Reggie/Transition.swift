import Foundation

/// A connection between two nodes which can determine the
/// progression of an automata with its predicate function.
public struct Transition<Node: Reggie.Node> {
  public typealias Input = Node.Input
  public typealias Meta = Node.Meta

  /// A function which determines whether or not the state machine should progress to
  /// this transition's `destination` node, and if so, what the resulting metadata should be.
  public var predicate: (Input, Meta) -> (Bool, Meta)

  /// The node that this transition should return when its
  /// `predicate` returns `true` with some metadata.
  public var destination: Node

  /// Create a new transition.
  /// - parameter node: The node to which the automata may be transitioned.
  /// - parameter condition: A function over a unit of input and some metadata which determines
  ///                        whether or not the automata should follow this transition.
  public init(to node: Node, when condition: @escaping (Input, Meta) -> (Bool, Meta)) {
    predicate = condition
    destination = node
  }

  /// Determine whether or not the automata's state machine should progress to the next node.
  /// - parameter input: A unit of input that may match this transition's the predicate.
  /// - parameter meta: Some metadata which can be used by the `predicate` function to help
  ///                   determine how the automata should progress.
  /// - returns: `nil` if the input doesn't match this transition's predicate.
  ///            If the input passes the predicate, a pairing of the next node for the automata,
  ///            as well as the resulting metadata for following this transition.
  public func traverse(with input: Input, _ meta: Meta) -> (Node, Meta)? {
    let (success, meta) = predicate(input, meta)
    guard success else { return nil }
    return (destination, meta)
  }
}

extension Transition where Node.Meta == () {
  public init(to node: Node, when condition: @escaping (Input) -> Bool) {
    self.init(to: node) { input, _  in (condition(input), ()) }
  }

  public func traverse(with input: Input) -> Node? {
    return self.traverse(with: input, ()).map { $0.0 }
  }
}
