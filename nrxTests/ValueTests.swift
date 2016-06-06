// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class ValueTests: XCTestCase {
	func testValueSizeLimit() {
		// The size of the Value type should not exceed some threshold.
		// Currently we're at 25 bytes, due to the `String` member's associated
		// value.
		XCTAssertLessThanOrEqual(sizeof(Value.self), 16, "Value type too big")
	}
}
