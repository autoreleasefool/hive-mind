import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CollectionExtensionTests.allTests),
    ]
}
#endif