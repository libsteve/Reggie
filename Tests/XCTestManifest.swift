import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [testCase(AutomataTests.allTests),
            testCase(LexerTests.allTests),
            testCase(PrefixedIteratorTests.allTests)]
}
#endif
