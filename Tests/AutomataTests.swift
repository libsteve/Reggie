import XCTest
@testable import Reggie

class AutomataTests: XCTestCase {

  func testTransition() {
    let a = NFA<String>()
    let t = Transition(to: a) { $0 == "a" }
    XCTAssertNotNil(t.traverse(with: "a"), "Transition over 'a' should be successful.")
    XCTAssertNil(t.traverse(with: "b"), "Transition over 'b' should fail.")
  }

  func testAutomata() {
    var a = NFA<String>()
    let b = NFA<String>(terminal: true)
    a.transition(to: b) { $0 == "b" }
    let m = Automata(root: a)
    XCTAssertTrue(m.advance(with: "b")!.isPassing, "The automata should contain 'b'.")
    XCTAssertNil(m.advance(with: "a"), "The automata should not contain 'a'.")
  }

  func testComplexAutomata() {
    var a = NFA<String>()
    var b = NFA<String>()
    let c = NFA<String>(terminal: true)
    a.transition(to: b) { $0 == "a" }
    b.transition(to: c) { $0 == "b" }
    let m = Automata(root: a)
    XCTAssertTrue(m.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertFalse(m.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(m.contains(input: ["b"]), "The automata should not contain 'b'.")
  }

  func testLoopingAutomata() {
    var a = NFA<String>()
    var b = NFA<String>()
    let c = NFA<String>(terminal: true)
    a.transition(to: b) { $0 == "a" }
    b.transition(to: c) { $0 == "b" }
    b.transition(to: b) { $0 == "a" }
    let m = Automata(root: a)
    XCTAssertTrue(m.contains(input: ["a", "b"]), "The automata should contain 'ab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "b"]), "The automata should contain 'aab'.")
    XCTAssertTrue(m.contains(input: ["a", "a", "a", "b"]), "The automata should contain 'aaab'.")
    XCTAssertFalse(m.contains(input: ["a"]), "The automata should not contain 'a'.")
    XCTAssertFalse(m.contains(input: ["b"]), "The automata should not contain 'b'.")
    XCTAssertFalse(m.contains(input: ["abb"]), "The automata should not contain 'abb'.")
  }

  func testOnePathFails() {
    var a = NFA<String>()
    var b = NFA<String>()
    var c = NFA<String>()
    let d = NFA<String>()
    let e = NFA<String>(terminal: true)
    let m = Automata(root: a)
    a.transition(to: b) { $0 == "a" }
    b.transition(to: c) { $0 == "b" }
    b.transition(to: d) { $0 == "b" }
    c.transition(to: e) { $0 == "c" }
    XCTAssertTrue(m.contains(input: ["a", "b", "c"]), "The automata should contain 'abd'.")
    XCTAssertFalse(m.contains(input: ["a", "b"]), "The automata should not contain 'ab'.")
    XCTAssertFalse(m.contains(input: ["a", "b", "d"]), "The automata should not contain 'abc'.")
  }
  
}
