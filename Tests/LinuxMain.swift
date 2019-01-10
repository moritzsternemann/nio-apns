import XCTest

import NIOAPNS_Tests

var tests = [XCTestCaseEntry]()
tests += APNSClientTests.allTests()
XCTMain(tests)