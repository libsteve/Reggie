import XCTest
@testable import Reggie

class ReggieTests: XCTestCase {

  func testTransition() {
    let a = NFA<String>()
    let t = Transition(to: a) { $0 == "a" }
    XCTAssertNotNil(t.traverse(with: "a"), "Transition over 'a' should be successful.")
    XCTAssertNil(t.traverse(with: "b"), "Transition over 'b' should fail.")
  }

  func testAutomata() {
    let a = NFA<String>()
    let b = NFA<String>(terminal: true)
    let t1 = Transition(to: b) { $0 == "b" }
    a.transitions.append(t1)
    let m = Automata(root: a)
    XCTAssertTrue(m.advance(with: "b").successful, "The automata should contain 'b'.")
    XCTAssertFalse(m.advance(with: "a").successful, "The automata should not contain 'a'.")
  }

  func testComplexAutomata() {
    let a = NFA<String>()
    let b = NFA<String>()
    let c = NFA<String>(terminal: true)
    let t1 = Transition(to: b) { $0 == "a" }
    let t2 = Transition(to: c) { $0 == "b" }
    a.transitions.append(t1)
    b.transitions.append(t2)
    let m = Automata(root: a)
    XCTAssertTrue(m.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertFalse(m.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(m.contains(input: ["b"]), "The automata should not contain 'b'.")
  }

  func testLoopingAutomata() {
    let a = NFA<String>()
    let b = NFA<String>()
    let c = NFA<String>(terminal: true)
    let t1 = Transition(to: b) { $0 == "a" }
    let t2 = Transition(to: c) { $0 == "b" }
    let t3 = Transition(to: b) { $0 == "a" }
    a.transitions.append(t1)
    b.transitions.append(t2)
    b.transitions.append(t3)
    let m = Automata(root: a)
    XCTAssertTrue(m.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "b"]), "The automata should contain 'aab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "a", "b"]), "The automata should contain 'aaab'.")
    XCTAssertFalse(m.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(m.contains(input: ["b"]), "The automata should not contain 'b'.")
    XCTAssertFalse(m.contains(input: ["abb"]), "The automata should not contain 'abb'.")
  }
  
}
