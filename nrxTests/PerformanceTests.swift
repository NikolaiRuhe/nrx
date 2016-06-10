// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class PerformanceTests: XCTestCase {

	override static func setUp() {
		// warm up the cache
		let _ = sourceBuffer
	}

	static var sourceString: String = {
		var source = "0\n"
		for index in 1...1000 {
			source += "\t+ (([\"0\", \"2\", \"\(index)\", $foo, [], \"Hello, World!\", \"\\\"\", \"1️⃣\"]"
			source += " map element : (NUMBER(element) except 0)) where each: each % 2 == 1).count"
		}
		return source
	}()

	static var sourceBuffer: [UInt8] = {
		var utf8 = Array(sourceString.utf8)
		utf8.append(0)
		return utf8
	}()

	func iterations(count: Int, body: ()-> Void) {
		#if NRX_OPTIMIZATION_ON
			for _ in 1...count {
				body()
			}
		#else
			body()
		#endif
	}

	func testLexerPerformance() {
		self.measureBlock {
			self.iterations(500) {
				var lexer = Lexer(zeroTerminatedUTF8FragmentBuffer: PerformanceTests.sourceBuffer)
				tokenLoop: while true {
					switch lexer.scanToken() {
					case .AtEnd:      break tokenLoop
					case .LexerError: XCTFail("unexpected lexer error")
					default:          continue
					}
				}
			}
		}
	}
}
