import XCTest
@testable import Reggie

let aRepeatingPattern: Automata<NFA<Character>> = {
  var a = NFA<Character>()
  var b = NFA<Character>(terminal: true)
  a.transition(to: b) { $0 == Character("a") }
  b.transition(to: b) { $0 == Character("a") }
  return Automata(root: a)
}()

class MatchGeneratorTests: XCTestCase {

  func testSimpleNoMatch() {
    var generator = MatchGenerator(reading: "b".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertNil(token)
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

  func testSimpleMatch() {
    var generator = MatchGenerator(reading: "aaa".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertNotNil(token)
    XCTAssertEqual(String(token!), "aaa")
    XCTAssertNil(generator.iterator.next())
  }

  func testSimplePartialMatch() {
    var generator = MatchGenerator(reading: "aaab".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertEqual(String(token!), "aaa")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

  func testSmallerSimplePartialMatch() {
    let automata = { () -> Automata<NFA<Character>> in
      var a = NFA<Character>()
      var b = NFA<Character>(terminal: true)
      var c = NFA<Character>()
      a.transition(to: b) { $0 == "a" }
      b.transition(to: c) { $0 == "b" }
      c.transition(to: c) { $0 == "b" }
      return Automata(root: a)
    }()

    var generator = MatchGenerator(reading: "abbb".characters)
    let token = generator.next(matching: automata)
    XCTAssertNotNil(token)
    XCTAssertEqual(String(token!), "a")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

}
