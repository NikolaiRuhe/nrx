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

		let source = ""
			+ "complex_abs(c)\n"
			+ "{\n"
			+ "    return c[0] * c[0] + c[1] * c[1];\n"
			+ "}\n"
			+ "\n"
			+ "complex_mult(a, b)\n"
			+ "{\n"
			+ "    return [a[0] * b[0] - a[1] * b[1], a[1] * b[0] + a[0] * b[1]];\n"
			+ "}\n"
			+ "\n"
			+ "complex_add(a, b)\n"
			+ "{\n"
			+ "    return [a[0] + b[0], a[1] + b[1]];\n"
			+ "}\n"
			+ "\n"
			+ "mandel(c)\n"
			+ "{\n"
			+ "    z := [0, 0];\n"
			+ "    h := 0;\n"
			+ "    while (h < 20) {\n"
			+ "        z := complex_add(complex_mult(z, z), c);\n"
			+ "        if (complex_abs(z) > 2)\n"
			+ "            return (h % 2) != 0 ? \" \" : \"+\";\n"
			+ "        h := h + 1;\n"
			+ "    }\n"
			+ "    return \"%\";\n"
			+ "}\n"
			+ "\n"
			+ "width  := 10;\n"
			+ "height := 10;\n"
			+ "\n"
			+ "x := 0.5;\n"
			+ "while (x < width)\n"
			+ "{\n"
			+ "    line := \"\";\n"
			+ "    real := 3 * (x / width - 0.5);\n"
			+ "\n"
			+ "    y := 0.5;\n"
			+ "    while (y < height)\n"
			+ "    {\n"
			+ "        img := 3 * (y / height - 0.5);\n"
			+ "        line := line + mandel([real, img]);\n"
			+ "        y := y + 1;\n"
			+ "    }\n"
			+ "    x := x + 1;\n"
			+ "    print line;\n"
			+ "}\n"

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

		performTest(input: source, expectedOutput: expectedOutput)
	}
}
