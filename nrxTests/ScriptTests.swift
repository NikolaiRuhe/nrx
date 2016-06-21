// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class ScriptTests: XCTestCase {

	func performTest(input input: String, expectedOutput: String, context: String = "", file: StaticString = #file, line: UInt = #line) {

		let parser = Parser(lexer: Lexer(source: input))
		guard let program = try? parser.parseProgram() else {
			XCTFail("unexpected parser error", file: file, line: line)
			return
		}
		let delegate = TestRuntimeDelegate()
		let runtime = Runtime(delegate: delegate)

		guard let _ = try? program.evaluate(runtime: runtime) else {
			XCTFail("unexpected evaluation error")
			return
		}
		let result = delegate.testNotation
		guard result == expectedOutput else {
			fail(actualResult: result, expectedResult: expectedOutput, context: context, file: file, line: line)
			return
		}
	}

	func testScript1() {
		performTest(input: "print \"Hello, world!\";", expectedOutput: "Hello, world!")
	}

	func testMandelbrot() {

		let source = readSource("mandelbrot")

		let expectedOutput = ""
			+ "++++++++++\n"
			+ "++++%%++++\n"
			+ "++      ++\n"
			+ "++ %%%% ++\n"
			+ "  %%%%%%  \n"
			+ "  +%%%%+  \n"
			+ "+  ++++  +\n"
			+ "+   ++   +\n"
			+ "++      ++\n"
			+ "++++  ++++"

		performTest(input: "width := 10; height := 10;\n" + source as String, expectedOutput: expectedOutput)
	}
}
