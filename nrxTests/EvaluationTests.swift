// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class EvaluationTests: XCTestCase {

	func performTest(input input: String, expectedOutput: String, context: String = "", file: StaticString = #file, line: UInt = #line) {

		class DummyContext : Runtime {}

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

		let result = (try? node.evaluate(runtime: DummyContext()))?.testNotation ?? "RUNTIME_ERROR"

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
		performTest(input: "1", expectedOutput: "1")
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
		performTest(input: "[1, 2, 3]", expectedOutput: "[1, 2, 3]")
	}

	func testMixedList() {
		performTest(input: "[true, \"foo\", 42]", expectedOutput: "[true, \"foo\", 42]")
	}

	func testEmptyDictionary() {
		performTest(input: "[:]", expectedOutput: "[:]")
	}

	func testSimpleDictionary() {
		performTest(input: "[\"a\":1, \"b\":2, \"c\":3]", expectedOutput: "[\"a\":1, \"b\":2, \"c\":3]")
	}

	func testSimpleDictionary_1() {
		performTest(input: "[\"b\":2, \"c\":3, \"a\":1]", expectedOutput: "[\"a\":1, \"b\":2, \"c\":3]")
	}

	func testSimpleDictionary_2() {
		performTest(input: "[\"b\":2, \"a\":1, \"c\":3]", expectedOutput: "[\"a\":1, \"b\":2, \"c\":3]")
	}

	func testMixedDictionary() {
		performTest(input: "[\"Bool\":true, \"String\":\"foo\", \"Number\":42]", expectedOutput: "[\"Bool\":true, \"Number\":42, \"String\":\"foo\"]")
	}

	func testDuplicateKeyDictionary() {
		performTest(input: "[\"foo\":1, \"foo\":1]", expectedOutput: "RUNTIME_ERROR")
	}

	func testNegation() {
		performTest(input: "-1", expectedOutput: "-1")
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

	func testExceptWithNoException() {
		performTest(input: "\"foo\" except \"bar\"", expectedOutput: "\"foo\"")
	}

	func testExceptWithLeftException() {
		performTest(input: "1/0 except \"bar\"", expectedOutput: "\"bar\"")
	}

	func testExceptWithRightException() {
		performTest(input: "1/0 except 2/0", expectedOutput: "RUNTIME_ERROR")
	}

	func testExceptChain() {
		performTest(input: "1/0 except 2/0 except \"fallback\"", expectedOutput: "\"fallback\"")
	}

	func testContains() {
		performTest(input: "[] contains 1", expectedOutput: "false")
	}

	func testContains_1() {
		performTest(input: "[1] contains 1", expectedOutput: "true")
	}

	func testContains_2() {
		performTest(input: "[:] contains 1", expectedOutput: "false")
	}

	func testContains_3() {
		performTest(input: "[\"foo\":\"bar\"] contains \"foo\"", expectedOutput: "true")
	}

	func testContains_4() {
		performTest(input: "1 contains 1", expectedOutput: "RUNTIME_ERROR")
	}

	func testLogicOr() {
		performTest(input: "true or true", expectedOutput: "true")
	}

	func testLogicOr_1() {
		performTest(input: "false or true", expectedOutput: "true")
	}

	func testLogicOr_2() {
		performTest(input: "true or false", expectedOutput: "true")
	}

	func testLogicOr_3() {
		performTest(input: "false or false", expectedOutput: "false")
	}

	func testLogicOrShortcut() {
		performTest(input: "true or 1/0", expectedOutput: "true")
	}

	func testLogicOrShortcut_1() {
		performTest(input: "false or 1/0", expectedOutput: "RUNTIME_ERROR")
	}

	func testLogicAnd() {
		performTest(input: "true and true", expectedOutput: "true")
	}

	func testLogicAnd_1() {
		performTest(input: "false and true", expectedOutput: "false")
	}

	func testLogicAnd_2() {
		performTest(input: "true and false", expectedOutput: "false")
	}

	func testLogicAnd_3() {
		performTest(input: "false and false", expectedOutput: "false")
	}

	func testLogicAndShortcut() {
		performTest(input: "false and 1/0", expectedOutput: "false")
	}

	func testLogicAndShortcut_1() {
		performTest(input: "true and 1/0", expectedOutput: "RUNTIME_ERROR")
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

	func testEquality_16() {
		performTest(input: "[1] == [1]", expectedOutput: "true")
	}

	func testEquality_17() {
		performTest(input: "[\"a\":1] == [\"a\":1]", expectedOutput: "true")
	}

	func testComparison() {
		performTest(input: "1 >  1", expectedOutput: "false")
	}

	func testComparison_1() {
		performTest(input: "1 >= 1", expectedOutput: "true")
	}

	func testComparison_2() {
		performTest(input: "1 <  1", expectedOutput: "false")
	}

	func testComparison_3() {
		performTest(input: "1 <= 1", expectedOutput: "true")
	}

	func testComparison_4() {
		performTest(input: "2 >  1", expectedOutput: "true")
	}

	func testComparison_5() {
		performTest(input: "2 >= 1", expectedOutput: "true")
	}

	func testComparison_6() {
		performTest(input: "2 <  1", expectedOutput: "false")
	}

	func testComparison_7() {
		performTest(input: "2 <= 1", expectedOutput: "false")
	}

	func testComparison_8() {
		performTest(input: "1 >  2", expectedOutput: "false")
	}

	func testComparison_9() {
		performTest(input: "1 >= 2", expectedOutput: "false")
	}

	func testComparison_10() {
		performTest(input: "1 <  2", expectedOutput: "true")
	}

	func testComparison_11() {
		performTest(input: "1 <= 2", expectedOutput: "true")
	}

	func testComparison_12() {
		performTest(input: "\"b\" > \"a\"", expectedOutput: "true")
	}

	func testComparison_13() {
		performTest(input: "\"b\" >= \"a\"", expectedOutput: "true")
	}

	func testComparison_14() {
		performTest(input: "\"a\" < \"b\"", expectedOutput: "true")
	}

	func testComparison_15() {
		performTest(input: "\"a\" <= \"b\"", expectedOutput: "true")
	}

	func testComparisonMismatchingTypes() {
		performTest(input: "1 >  \"a\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testComparisonMismatchingTypes_1() {
		performTest(input: "1 >= \"a\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testComparisonMismatchingTypes_2() {
		performTest(input: "1 <  \"a\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testComparisonMismatchingTypes_3() {
		performTest(input: "1 <= \"a\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testAddition() {
		performTest(input: "1 + 2", expectedOutput: "3")
	}

	func testAdditionStrings() {
		performTest(input: "\"foo\" + \"bar\"", expectedOutput: "\"foobar\"")
	}

	func testAdditionUnsupportedTypes() {
		performTest(input: "true + true", expectedOutput: "RUNTIME_ERROR")
	}

	func testSubtraction() {
		performTest(input: "2 - 1", expectedOutput: "1")
	}

	func testSubtractionUnsupportedTypes() {
		performTest(input: "\"foo\" - \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testMultiplication() {
		performTest(input: "1 * 2", expectedOutput: "2")
	}

	func testMultiplicationUnsupportedTypes() {
		performTest(input: "\"foo\" * \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testDivision() {
		performTest(input: "65536 / 256", expectedOutput: "256")
	}

	func testDivisionByZero() {
		performTest(input: "42 / 0", expectedOutput: "RUNTIME_ERROR")
	}

	func testDivisionUnsupportedTypes() {
		performTest(input: "\"foo\" / \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testModulo() {
		performTest(input: "5 % 4", expectedOutput: "1")
	}

	func testModuloByZero() {
		performTest(input: "42 % 0", expectedOutput: "RUNTIME_ERROR")
	}

	func testModuloUnsupportedTypes() {
		performTest(input: "\"foo\" % \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testConditionalOperator() {
		performTest(input: "true ? \"foo\" : \"bar\"", expectedOutput: "\"foo\"")
	}

	func testConditionalOperator_1() {
		performTest(input: "false ? \"foo\" : \"bar\"", expectedOutput: "\"bar\"")
	}

	func testConditionalOperatorBadType() {
		performTest(input: "\"baz\" ? \"foo\" : \"bar\"", expectedOutput: "RUNTIME_ERROR")
	}

	func testConditionalOperatorShortcut() {
		performTest(input: "true ? \"foo\" : 1/0", expectedOutput: "\"foo\"")
	}

	func testConditionalOperatorShortcut_1() {
		performTest(input: "false ? 1/0 : \"bar\"", expectedOutput: "\"bar\"")
	}

	func testSimpleExpression() {
		performTest(input: "1 + 2 * 3", expectedOutput: "7")
	}

}
