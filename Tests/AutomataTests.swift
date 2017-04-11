import XCTest
@testable import Reggie

class AutomataTests: XCTestCase {

  func testTransition() {
    let a = State(),
        t = Transition<String, ()>(to: a) { ($0.0 == "a", ()) }
    XCTAssertNotNil(t.traverse(with: "a", ()), "Transition over 'a' should be successful.")
    XCTAssertNil(t.traverse(with: "b", ()), "Transition over 'b' should fail.")
  }

  func testAutomata() {
    var nfa = NFA<String>()
    let a = nfa.root,
        b = State()
    nfa.mark(b, as: .terminating)
    nfa.transition(from: a, to: b) { $0 == "b" }
    XCTAssertTrue(nfa.advance(with: "b")!.isPassing, "The automata should contain 'b'.")
    XCTAssertNil(nfa.advance(with: "a"), "The automata should not contain 'a'.")
  }

  func testComplexAutomata() {
    var nfa = NFA<String>()
    let a = nfa.root,
        b = State(),
        c = State()
    nfa.mark(c, as: .terminating)
    nfa.transition(from: a, to: b) { $0 == "a" }
    nfa.transition(from: b, to: c) { $0 == "b" }
    XCTAssertTrue(nfa.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertFalse(nfa.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(nfa.contains(input: ["b"]), "The automata should not contain 'b'.")
  }

  func testLoopingAutomata() {
    var m = NFA<String>()
    let a = m.root,
        b = State(),
        c = State()
    m.mark(c, as: .terminating)
    m.transition(from: a, to: b) { $0 == "a" }
    m.transition(from: b, to: c) { $0 == "b" }
    m.transition(from: b, to: b) { $0 == "a" }
    XCTAssertTrue(m.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "b"]), "The automata should contain 'aab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "a", "b"]), "The automata should contain 'aaab'.")
    XCTAssertFalse(m.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(m.contains(input: ["b"]), "The automata should not contain 'b'.")
    XCTAssertFalse(m.contains(input: ["abb"]), "The automata should not contain 'abb'.")
  }

  func testOnePathFails() {
    var m = NFA<String>()
    let a = m.root,
        b = State(),
        c = State(),
        d = State(),
        e = State()
    m.mark(e, as: .terminating)
    m.transition(from: a, to: b) { $0 == "a" }
    m.transition(from: b, to: c) { $0 == "b" }
    m.transition(from: b, to: d) { $0 == "b" }
    m.transition(from: c, to: e) { $0 == "c" }
    XCTAssertTrue(m.contains(input: ["a", "b", "c"]), "The automata should contain 'abd'.")
    XCTAssertFalse(m.contains(input: ["a", "b"]), "The automata should not contain 'ab'.")
    XCTAssertFalse(m.contains(input: ["a", "b", "d"]), "The automata should not contain 'abc'.")
  }
  
}
