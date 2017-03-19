import XCTest
@testable import Reggie

class PrefixedIteratorTests: XCTestCase {

  func testBuffered() {
    let iterator = [1, 2, 3].makeIterator()
    let buffer = [9, 8, 7]
    var prefixed = PrefixedIterator(emitting: buffer, before: iterator)
    XCTAssertEqual(prefixed.next(), 9)
    XCTAssertEqual(prefixed.next(), 8)
    XCTAssertEqual(prefixed.next(), 7)
    XCTAssertEqual(prefixed.next(), 1)
    XCTAssertEqual(prefixed.next(), 2)
    XCTAssertEqual(prefixed.next(), 3)
    XCTAssertNil(prefixed.next())
  }

}
