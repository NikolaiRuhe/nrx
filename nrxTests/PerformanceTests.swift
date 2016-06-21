// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class PerformanceTests: XCTestCase {

	override static func setUp() {
		// warm up the cache
		let _ = sourceBuffer
	}

	private static var optimizedBuild: Bool {
		#if NRX_OPTIMIZATION_ON
			return true
		#else
			return false
		#endif
	}

	private var optimizedBuild: Bool {
		return PerformanceTests.optimizedBuild
	}

	static var sourceString: String = {
		var source = "0\n"

		for index in 1...(optimizedBuild ? 1000 : 1) {
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
		for _ in 1...(optimizedBuild ? count : 1) {
			body()
		}
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

	func testParserPerformance() {
		self.measureBlock {
			self.iterations(50) {
				let parser = Parser(lexer: Lexer(zeroTerminatedUTF8FragmentBuffer: PerformanceTests.sourceBuffer))
				let node = try? parser.parseExpression()
				XCTAssertNotNil(node)
				XCTAssertTrue(parser.isAtEnd)
			}
		}
	}

	func testRuntimePerformance() {
		let parser = Parser(lexer: Lexer(zeroTerminatedUTF8FragmentBuffer: PerformanceTests.sourceBuffer))
		guard let node = try? parser.parseExpression() else {
			XCTFail("parising failed unexpectedly")
			return
		}
		XCTAssertTrue(parser.isAtEnd)

		class TestDelegate : RuntimeDelegate {
			func print(string: String) {
			}

			func resolve(symbol: String) -> Value? {
				if symbol == "NUMBER" {
					return Value.Callable(NUMBER())
				}
				return nil
			}
			func lookup(lookup: LookupDescription) -> Value? {
				return Value("foo")
			}
			class NUMBER: Callable {
				var parameterNames: [String] { return ["value"] }
				func body(runtime runtime: Runtime) throws -> Value {
					let value = try runtime.resolve("value")
					switch value {
					case .Number:
						return value
					case .String(let string):
						if let number = Float64(string.value) {
							return Value(number)
						}
					default:
						break
					}
					throw EvaluationError.Exception(reason: "could not convert to number")
				}
			}
		}

		let delegate = TestDelegate()
		let runtime = Runtime(delegate: delegate)

		self.measureBlock {
			self.iterations(5) {
				let result = try? node.evaluate(runtime: runtime)
				#if NRX_OPTIMIZATION_ON
					XCTAssertEqual(result, Value(500.0))
				#else
					XCTAssertEqual(result, Value(1.0))
				#endif
			}
		}
	}

	func testMandelbrotPerformance() {
		guard optimizedBuild else {
			return
		}

		let source = "width := 100; height := 100;\n" + readSource("mandelbrot")

		let parser = Parser(lexer: Lexer(source: source))
		guard let program = try? parser.parseProgram() else {
			XCTFail("parising failed unexpectedly")
			return
		}
		XCTAssertTrue(parser.isAtEnd)

		let delegate = TestRuntimeDelegate()
		let runtime = Runtime(delegate: delegate)

		#if NRX_OPTIMIZATION_ON
			self.measureBlock {
				let _ = try? program.evaluate(runtime: runtime)
			}
		#else
			let _ = try? program.evaluate(runtime: runtime)
		#endif
	}
}
