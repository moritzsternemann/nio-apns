import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APNSClientTests.allTests),
        testCase(APNSPayloadTests.allTests)
    ]
}
#endif
