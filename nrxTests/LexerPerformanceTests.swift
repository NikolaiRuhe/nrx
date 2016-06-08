// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class AdditionalLexerTests: XCTestCase {

	func performPerformanceTest(input input: String, file: StaticString = #file, line: UInt = #line) {

		var sut = Lexer(source: input)

		tokenLoop: while true {
			let token = sut.scanToken()
			switch token {
			case .AtEnd:
				break tokenLoop
			case .LexerError:
				XCTFail("unexpected lexer error", file: file, line: line)
				return
			default:
				continue
			}
		}
	}

	func testPerformanceWithHugeInput() {
		var input = "0\n"
		for _ in 1...1000 {
			input += "\t+ [ \"1\", \"2\", \"3\", $foo, [], \"Hello, World!\", \"\\\"\", \"1️⃣\" ] ((map element : NUMBER(element)) where each: each % 2 == 1).count\n"
		}

		self.measureBlock {
			for _ in 1...100 {
				self.performPerformanceTest(input: input)
			}
		}
	}

}
