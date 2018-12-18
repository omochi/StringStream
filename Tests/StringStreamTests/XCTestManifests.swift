import XCTest

extension CharacterReaderTests {
    static let __allTests = [
        ("test1", test1),
    ]
}

extension UTF8ReaderTests {
    static let __allTests = [
        ("test1", test1),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CharacterReaderTests.__allTests),
        testCase(UTF8ReaderTests.__allTests),
    ]
}
#endif
