// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class EvaluationTests: XCTestCase {

	func performTest(input input: String, expectedOutput: String, context: String = "", file: StaticString = #file, line: UInt = #line) {

		class DummyContext : EvaluationContext {}

		let lexer = Lexer(source: input)
		let sut = Parser(lexer: lexer)

		guard let node = try? sut.parse() else {
			XCTFail("could not parse input", file: file, line: line)
			return
		}
		if !sut.isAtEnd {
			XCTFail("could not parse input", file: file, line: line)
			return
		}

		let result = (try? node.evaluate(context: DummyContext()))?.testNotation ?? "RUNTIME_ERROR"

		guard result == expectedOutput else {
			fail(actualResult: result, expectedResult: expectedOutput, context: context, file: file, line: line)
			return
		}
	}
}

// --------- generated tests below this line: do not edit ---------

extension EvaluationTests {

	func testNull() {
		performTest(input: "NULL", expectedOutput: "NULL")
	}

	func testBoolTrue() {
		performTest(input: "true", expectedOutput: "true")
	}

	func testBoolFalse() {
		performTest(input: "false", expectedOutput: "false")
	}

	func testNumberInt() {
		performTest(input: "1", expectedOutput: "1.0")
	}

	func testNumberFloat() {
		performTest(input: "2.5", expectedOutput: "2.5")
	}

	func testEmptyString() {
		performTest(input: "\"\"", expectedOutput: "\"\"")
	}

	func testHelloString() {
		performTest(input: "\"Hello, World\"", expectedOutput: "\"Hello, World\"")
	}

	func testEscapedString() {
		performTest(input: "\"\\\"foo\\\"\"", expectedOutput: "\"\\\"foo\\\"\"")
	}

	func testEmptyList() {
		performTest(input: "[]", expectedOutput: "[]")
	}

	func testSimpleList() {
		performTest(input: "[1, 2, 3]", expectedOutput: "[1.0, 2.0, 3.0]")
	}

	func testMixedList() {
		performTest(input: "[true, \"foo\", 42]", expectedOutput: "[true, \"foo\", 42.0]")
	}

	func testEmptyDictionary() {
		performTest(input: "[:]", expectedOutput: "[:]")
	}

	func testSimpleDictionary() {
		performTest(input: "[\"a\":1, \"b\":2, \"c\":3]", expectedOutput: "[\"a\":1.0, \"b\":2.0, \"c\":3.0]")
	}

	func testSimpleDictionary_1() {
		performTest(input: "[\"b\":2, \"c\":3, \"a\":1]", expectedOutput: "[\"a\":1.0, \"b\":2.0, \"c\":3.0]")
	}

	func testSimpleDictionary_2() {
		performTest(input: "[\"b\":2, \"a\":1, \"c\":3]", expectedOutput: "[\"a\":1.0, \"b\":2.0, \"c\":3.0]")
	}

	func testMixedDictionary() {
		performTest(input: "[\"Bool\":true, \"String\":\"foo\", \"Number\":42]", expectedOutput: "[\"Bool\":true, \"Number\":42.0, \"String\":\"foo\"]")
	}

	func testDuplicateKeyDictionary() {
		performTest(input: "[\"foo\":1, \"foo\":1]", expectedOutput: "RUNTIME_ERROR")
	}

	func testNegation() {
		performTest(input: "-1", expectedOutput: "-1.0")
	}

	func testNegationBadType() {
		performTest(input: "-\"foo\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testLogicNegation() {
		performTest(input: "!true", expectedOutput: "false")
	}

	func testLogicNegationBadType() {
		performTest(input: "!\"foo\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testEquality() {
		performTest(input: "NULL == NULL", expectedOutput: "true")
	}

	func testEquality_1() {
		performTest(input: "NULL != NULL", expectedOutput: "false")
	}

	func testEquality_2() {
		performTest(input: "true == true", expectedOutput: "true")
	}

	func testEquality_3() {
		performTest(input: "true != true", expectedOutput: "false")
	}

	func testEquality_4() {
		performTest(input: "false == false", expectedOutput: "true")
	}

	func testEquality_5() {
		performTest(input: "false != false", expectedOutput: "false")
	}

	func testEquality_6() {
		performTest(input: "false == true", expectedOutput: "false")
	}

	func testEquality_7() {
		performTest(input: "false != true", expectedOutput: "true")
	}

	func testEquality_8() {
		performTest(input: "false == NULL", expectedOutput: "false")
	}

	func testEquality_9() {
		performTest(input: "false != NULL", expectedOutput: "true")
	}

	func testEquality_10() {
		performTest(input: "1 == 1", expectedOutput: "true")
	}

	func testEquality_11() {
		performTest(input: "1 != 1", expectedOutput: "false")
	}

	func testEquality_12() {
		performTest(input: "1 == 2", expectedOutput: "false")
	}

	func testEquality_13() {
		performTest(input: "1 != 2", expectedOutput: "true")
	}

	func testEquality_14() {
		performTest(input: "\"foo\" == \"foo\"", expectedOutput: "true")
	}

	func testEquality_15() {
		performTest(input: "\"foo\" != \"foo\"", expectedOutput: "false")
	}

	func testAddition() {
		performTest(input: "1 + 2", expectedOutput: "3.0")
	}

	func testAdditionStrings() {
		performTest(input: "\"foo\" + \"bar\"", expectedOutput: "\"foobar\"")
	}

	func testAdditionBadTypes() {
		performTest(input: "1 + true", expectedOutput: "RUNTIME_ERROR")
	}

	func testSubtraction() {
		performTest(input: "2 - 1", expectedOutput: "1.0")
	}

	func testSubtractionBadTypes() {
		performTest(input: "\"foo\" - \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testMultiplication() {
		performTest(input: "1 * 2", expectedOutput: "2.0")
	}

	func testMultiplicationBadTypes() {
		performTest(input: "\"foo\" * \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testDivision() {
		performTest(input: "65536 / 256", expectedOutput: "256.0")
	}

	func testDivisionByZero() {
		performTest(input: "42 / 0", expectedOutput: "RUNTIME_ERROR")
	}

	func testDivisionBadTypes() {
		performTest(input: "\"foo\" / \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testModulo() {
		performTest(input: "5 % 4", expectedOutput: "1.0")
	}

	func testModuloByZero() {
		performTest(input: "42 % 0", expectedOutput: "RUNTIME_ERROR")
	}

	func testModuloBadTypes() {
		performTest(input: "\"foo\" % \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testSimpleExpression() {
		performTest(input: "1 + 2 * 3", expectedOutput: "7.0")
	}

}
