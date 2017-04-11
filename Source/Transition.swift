import Foundation

/// A connection between two state nodes which can determine the
/// progression of an automata with its predicate function.
struct Transition<Input, Meta> {
  /// A function which determines whether or not the state machine should progress to
  /// this transition's `destination` state, and if so, what the resulting metadata should be.
  public var predicate: (Input, Meta) -> (Bool, Meta)

  /// The state node that this transition should return when its
  /// `predicate` returns `true` with some metadata.
  public var destination: State

  /// Create a new transition.
  /// - parameter state: The state node to which the automata may be transitioned.
  /// - parameter condition: A function over a unit of input and some metadata which determines
  ///                        whether or not the automata should follow this transition.
  public init(to state: State, when condition: @escaping (Input, Meta) -> (Bool, Meta)) {
    predicate = condition
    destination = state
  }

  /// Determine whether or not the automata's state machine should progress to the next state node.
  /// - parameter input: A unit of input that may match this transition's the predicate.
  /// - parameter meta: Some metadata which can be used by the `predicate` function to help
  ///                   determine how the automata should progress.
  /// - returns: `nil` if the input doesn't match this transition's predicate.
  ///            If the input passes the predicate, a pairing of the next state for the automata,
  ///            as well as the resulting metadata after following this transition.
  public func traverse(with input: Input, _ meta: Meta) -> (State, Meta)? {
    let (success, meta) = predicate(input, meta)
    guard success else { return nil }
    return (destination, meta)
  }
}
