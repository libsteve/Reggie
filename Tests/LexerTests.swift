import XCTest
@testable import Reggie

let aRepeatingPattern: NFA<Character> = {
  var m = NFA<Character>()
  let a = m.root,
      b = State()
  m.mark(b, as: .terminating)
  m.transition(from: a, to: b) { $0 == Character("a") }
  m.transition(from: b, to: b) { $0 == Character("a") }
  return m
}()

let anotherRepeatingPattern: NFA<Character> = {
  var m = NFA<Character>()
  let a = m.root,
  b = State(),
  c = State()
  m.mark(b, as: .terminating)
  m.transition(from: a, to: b) { $0 == "a" }
  m.transition(from: b, to: c) { $0 == "b" }
  m.transition(from: c, to: c) { $0 == "b" }
  return m
}()

class LexerTests: XCTestCase {

  func testSimpleNoMatch() {
    var generator = Lexer(reading: "b".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertNil(token)
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

  func testSimpleMatch() {
    var generator = Lexer(reading: "aaa".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertNotNil(token)
    XCTAssertEqual(String(token!), "aaa")
    XCTAssertNil(generator.iterator.next())
  }

  func testSimplePartialMatch() {
    var generator = Lexer(reading: "aaab".characters)
    let token = generator.next(matching: aRepeatingPattern)
    XCTAssertEqual(String(token!), "aaa")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

  func testSmallerSimplePartialMatch() {
    var generator = Lexer(reading: "abbb".characters)
    let token = generator.next(matching: anotherRepeatingPattern)
    XCTAssertNotNil(token)
    XCTAssertEqual(String(token!), "a")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertEqual(generator.iterator.next(), "b")
    XCTAssertNil(generator.iterator.next())
  }

}
