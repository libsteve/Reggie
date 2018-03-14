import Foundation

/// A state machine which is a function over a given input type.
///
/// This data structure can be used to represent a "language" of
/// combinations of the given input type's instances.
public struct Automata<Input, Meta> {
  typealias Transition = Reggie.Transition<Input, Meta>

  /// The state node from which the automata starts evaluating input.
  public let root: State = State()

  /// The initial value of the meta data when the automata starts evaluating input.
  public let base: Meta

  /// The set of all state nodes within the auotmata which are terminating,
  /// meaning that they mark the end of a possible "word" within the automata's "language".
  public fileprivate(set) var terminals: Set<State> = []

  /// The set of all state nodes within the automata.
  public var states: Set<State> { return Set(self.transitions.keys) }

  /// A mapping of state nodes to 
  var transitions: [State : [Transition]]

  /// A pairing of currently visited state nodes with their corresponding metadata.
  var current: [(State, Meta)]

  /// Create a new automata using the specified initial root state and metadata.
  /// - parameter meta: Any initial metadata value that should accompany evaluated state nodes.
  public init(base meta: Meta) {
    base = meta
    current = [(root, base)]
    transitions = [self.root : []]
  }
}

extension Automata {
  /// Connect two state nodes with a predicate transition.
  /// - parameter source: The state node from where the transition should begin.
  /// - parameter destination: The state node to where the successful transition should result.
  /// - parameter transition: A predicate function which determines whether the given input and
  ///                         metadata are sufficient to traverse the connection between states.
  public mutating func transition(from source: State,
                                  to destination: State,
                                  over transition: @escaping (Input, Meta) -> (Bool, Meta)) {
    if transitions[source] == nil { transitions[source] = [] }
    if transitions[destination] == nil { transitions[destination] = [] }
    transitions[source]?.append(Transition(to: destination, when: transition))
  }

  /// Determine whether or not a given state denotes
  /// the possible end of a matching "word" within the automata's "language".
  /// - parameter state: The state node whose termination status should be modified.
  /// - parameter terminating: The value to which the state's termination status should be set.
  public mutating func mark(_ state: State, as terminating: Termination) {
    switch terminating {
    case .terminating:
      terminals.insert(state)
      if transitions[state] == nil { transitions[state] = [] }
    case .nonterminating:
      terminals.remove(state)
      if transitions[state]?.isEmpty ?? false { transitions[state] = nil }
    }
  }

  /// Determine whether or not a given state denotes
  /// the possible end of a matching "word" within the automata's "language".
  /// - parameter state: The state node whose termination status should be modified.
  /// - parameter terminal: A boolean value denoting whether or not the state node
  ///                       represents the end of a possible match within the automata.
  public mutating func set(_ state: State, terminal: Bool) {
    mark(state, as: terminal ? .terminating : .nonterminating)
  }
}

extension Automata where Meta == () {
  /// Create a new automata using the specified initial root state node
  /// which doesn't require metadata to operate.
  public init() {
    self.init(base: ())
  }

  /// Connect two state nodes with a predicate transition.
  /// - parameter source: The state node from where the transition should begin.
  /// - parameter destination: The state node to where the successful transition should result.
  /// - parameter transition: A predicate function which determines whether the given input is
  ///                         sufficient to traverse the connection between states.
  public mutating func transition(from source: State,
                                  to destination: State,
                                  over transition: @escaping (Input) -> Bool) {
    self.transition(from: source, to: destination) { (input: (Input, Meta)) -> (Bool, Meta) in
      let (input, _) = input
      return (transition(input), ())
    }
  }
}

extension Automata {
  /// Indicate whether or not the automata is in a successfully terminating position.
  /// - returns: `true` when any of the states current within this automata are terminal.
  public var isPassing: Bool {
    return current.reduce(false) { $0 || terminals.contains($1.0) }
  }

  public var passingMeta: [Meta] {
    return current.reduce([] as [Meta]) { collected, pair in
      var collected = collected
      let (state, meta) = pair
      if terminals.contains(state) { collected.append(meta) }
      return collected
    }
  }

  /// Evaluate the automata with the given input.
  /// - parameter input: A unit of input data which can allow the automata's
  ///                    internal state machine to advance by one transition.
  /// - returns: An automata with an internal state machine that has advanced according
  ///            to the given input. Otherwise, if the input does not result in the
  ///            successful transition from one state node to another, `nil` is returned.
  public func advance(with input: Input) -> Automata? {
    let nextStates = current.flatMap { state -> [(State, Meta)] in
      let (state, meta) = state
      return transitions[state]?.flatMap { $0.traverse(with:input, meta) } ?? []
    }
    if nextStates.isEmpty { return nil }
    var result = self
    result.current = nextStates
    return result
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

extension Automata {
  /// Reset each state node within the automata to a new unique value
  /// while presetving inter-node relationships.
  public mutating func remap() {
    let mapping: [State : State] = {
      var mapping: [State : State] = [:]
      let pairs = transitions.keys.map { ($0, State()) }
      for (original, remapped) in pairs {
        mapping[original] = remapped
      }
      return mapping
    }()

    transitions = {
      var transitions: [State: [Transition]] = [:]
      for state in self.transitions.keys {
        transitions[mapping[state]!] = self.transitions[state]!.map { transition in
          var transition = transition
          transition.destination = mapping[transition.destination]!
          return transition
        }
      }
      return transitions
    }()

    terminals = {
      var terminals: Set<State> = []
      for state in self.terminals {
        terminals.insert(mapping[state]!)
      }
      return terminals
    }()
  }

  /// Reset each state node within the automata to a new unique value
  /// while presetving inter-node relationships.
  /// - returns: A new automata instance with each state node reset to a new unique identity.
  public func remapped() -> Automata {
    var copy = self
    copy.remap()
    return copy
  }
}

/// An implementation for a Non-Deterministic Finite Automata.
public typealias NFA<Reading> = Automata<Reading, ()>

/// An implementation for a Push-Down Automata.
public typealias PDA<Reading, Marker> = Automata<Reading, Marker>
