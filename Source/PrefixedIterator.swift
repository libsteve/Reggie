import Foundation

/// An iterator which will return values from a given sequence before returning its
/// given interator's values.
struct PrefixedIterator<Element>: IteratorProtocol {
  private var buffer: AnyIterator<Element>
  private var iterator: AnyIterator<Element>

  /// Create a new prefixed iterator.
  /// - parameter elements: A sequence of values which should be returned before consuming the
  ///                       given iterator's values.
  /// - parameter iterator: An iterator whose values will be emitted after the buffer's elements
  ///                       have been iterated over.
  init<Elements: Sequence, Iterator: IteratorProtocol>(emitting elements: Elements,
                                                       before iterator: Iterator)
    where Element == Elements.Iterator.Element, Element == Iterator.Element {
      self.buffer = AnyIterator(elements.makeIterator())
      self.iterator = AnyIterator(iterator)
  }

  mutating func next() -> Element? {
    return buffer.next() ?? iterator.next()
  }
}

extension AnyIterator {
  /// Create an iterator which will emit values from the given sequence of elements before
  /// emitting values from the given iterator.
  /// - parameter elements: A buffer of values to emit before emitting
  ///                       the wrapped iterator's values.
  /// - parameter iterator: An iterator to wrap, whose values will be returned after iterating
  ///                       over the values in the given buffer.
  init<Elements: Sequence, Iterator: IteratorProtocol>(emitting elements: Elements,
                                                       before iterator: Iterator)
    where Element == Elements.Iterator.Element, Element == Iterator.Element {
      self = AnyIterator(PrefixedIterator(emitting: elements, before: iterator))
  }
}
