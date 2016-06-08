// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class ParserTests: XCTestCase {

	func performTest(input input: String, expectedOutput: String, context: String = "", file: StaticString = #file, line: UInt = #line) {

		let lexer = Lexer(source: input)
		let sut = Parser(lexer: lexer)

		var result = (try? sut.parse())?.testNotation ?? "PARSER_ERROR"
		if !sut.isAtEnd {
			result = "PARSER_ERROR"
		}

		guard result == expectedOutput else {
			fail(actualResult: result, expectedResult: expectedOutput, context: context, file: file, line: line)
			return
		}
	}
}
// --------- generated tests below this line: do not edit ---------

extension ParserTests {

	func testEmpty() {
		performTest(input: "", expectedOutput: "PARSER_ERROR")
	}

	func testEmptyExpression() {
		performTest(input: "()", expectedOutput: "PARSER_ERROR")
	}

	func testInvalidToken() {
		performTest(input: "$0", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken() {
		performTest(input: ")", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_1() {
		performTest(input: "]", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_2() {
		performTest(input: "*", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_3() {
		performTest(input: "/", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_4() {
		performTest(input: "%", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_5() {
		performTest(input: "+", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_6() {
		performTest(input: "?", expectedOutput: "PARSER_ERROR")
	}

	func testUnexpectedToken_7() {
		performTest(input: "]", expectedOutput: "PARSER_ERROR")
	}

	func testTwoExpressions() {
		performTest(input: "1 2", expectedOutput: "PARSER_ERROR")
	}

	func testIntLiteral() {
		performTest(input: "1", expectedOutput: "1")
	}

	func testFloatLiteral01() {
		performTest(input: "0.1", expectedOutput: "0.1")
	}

	func testFloatLiteral10() {
		performTest(input: "1.0", expectedOutput: "1")
	}

	func testStringLiteral() {
		performTest(input: "\"default\"", expectedOutput: "\"default\"")
	}

	func testBoolLiteral() {
		performTest(input: "true", expectedOutput: "true")
	}

	func testNullLiteral() {
		performTest(input: "NULL", expectedOutput: "NULL")
	}

	func testEmptyListLiteral() {
		performTest(input: "[]", expectedOutput: "[]")
	}

	func testListLiteral() {
		performTest(input: "[1 ]", expectedOutput: "[1]")
	}

	func testListLiteral_1() {
		performTest(input: "[1, ]", expectedOutput: "[1]")
	}

	func testListLiteral_2() {
		performTest(input: "[1, 2, 3 ]", expectedOutput: "[1, 2, 3]")
	}

	func testListLiteral_3() {
		performTest(input: "[1, 2, 3, ]", expectedOutput: "[1, 2, 3]")
	}

	func testListLiteral_4() {
		performTest(input: "[1, 0.2, \"abc\", false, [0], [1:2], $abc]", expectedOutput: "[1, 0.2, \"abc\", false, [0], [1:2], $abc]")
	}

	func testListLiteral_5() {
		performTest(input: "[1, 0.2, \"abc\", false, [0], [1:2], $abc, ]", expectedOutput: "[1, 0.2, \"abc\", false, [0], [1:2], $abc]")
	}

	func testMalformedListLiteral() {
		performTest(input: "[", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedListLiteral_1() {
		performTest(input: "[,]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedListLiteral_2() {
		performTest(input: "[ /* 1 */, 2, 3]", expectedOutput: "PARSER_ERROR")
	}

	func testEmptyDictLiteral() {
		performTest(input: "[:]", expectedOutput: "[:]")
	}

	func testDictLiteral() {
		performTest(input: "[1:2]", expectedOutput: "[1:2]")
	}

	func testDictLiteral_1() {
		performTest(input: "[1:2, ]", expectedOutput: "[1:2]")
	}

	func testDictLiteral_2() {
		performTest(input: "[1:2, 2:3, 3:4]", expectedOutput: "[1:2, 2:3, 3:4]")
	}

	func testDictLiteral_3() {
		performTest(input: "[1:2, 2:3, 3:4, ]", expectedOutput: "[1:2, 2:3, 3:4]")
	}

	func testDictLiteral_4() {
		performTest(input: "[\"1\":1, \"0.2\":0.2, \"abc\":\"abc\", \"false\":false, \"[0]\":[0], \"[1:2]\":[1:2], \"$abc\":$abc]", expectedOutput: "[\"1\":1, \"0.2\":0.2, \"abc\":\"abc\", \"false\":false, \"[0]\":[0], \"[1:2]\":[1:2], \"$abc\":$abc]")
	}

	func testDictLiteral_5() {
		performTest(input: "[\"1\":1, \"0.2\":0.2, \"abc\":\"abc\", \"false\":false, \"[0]\":[0], \"[1:2]\":[1:2], \"$abc\":$abc, ]", expectedOutput: "[\"1\":1, \"0.2\":0.2, \"abc\":\"abc\", \"false\":false, \"[0]\":[0], \"[1:2]\":[1:2], \"$abc\":$abc]")
	}

	func testMalformedDictLiteral() {
		performTest(input: "[ 1;", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_1() {
		performTest(input: "[ 1:2", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_2() {
		performTest(input: "[ 1:2, 1 2]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_3() {
		performTest(input: "[ 1: ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_4() {
		performTest(input: "[ :1 ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_5() {
		performTest(input: "[ 1:1, 1: ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_6() {
		performTest(input: "[ 1:1, :1 ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_7() {
		performTest(input: "[ 1:1:1 ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_8() {
		performTest(input: "[ 1, 1:1 ]", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedDictLiteral_9() {
		performTest(input: "[ 1:1, 1 ]", expectedOutput: "PARSER_ERROR")
	}

	func testSingleLookup() {
		performTest(input: "$a", expectedOutput: "$a")
	}

	func testMultiLookup() {
		performTest(input: "$$a", expectedOutput: "$$a")
	}

	func testLookupChain() {
		performTest(input: "$a$$b$c$$d", expectedOutput: "$a$$b$c$$d")
	}

	func testIdentifier() {
		performTest(input: "myName", expectedOutput: "myName")
	}

	func testUnaryminus() {
		performTest(input: "-a", expectedOutput: "(-a)")
	}

	func testUnaryminus_1() {
		performTest(input: "--a", expectedOutput: "(-(-a))")
	}

	func testUnaryminus_2() {
		performTest(input: "(-/* foo */a)", expectedOutput: "(-a)")
	}

	func testUnarynot() {
		performTest(input: "!a", expectedOutput: "(!a)")
	}

	func testUnarynot_1() {
		performTest(input: "!!a", expectedOutput: "(!(!a))")
	}

	func testUnarymix() {
		performTest(input: "-!-!a", expectedOutput: "(-(!(-(!a))))")
	}

	func testParenthesis() {
		performTest(input: "(a)", expectedOutput: "a")
	}

	func testParenthesis_1() {
		performTest(input: "((a))", expectedOutput: "a")
	}

	func testMalformedParenthesis() {
		performTest(input: "(", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedParenthesis_1() {
		performTest(input: ")", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedParenthesis_2() {
		performTest(input: "() 1", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedParenthesis_3() {
		performTest(input: "-()", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedParenthesis_4() {
		performTest(input: "(-1+)", expectedOutput: "PARSER_ERROR")
	}

	func testExceptOperator() {
		performTest(input: "1 except 2", expectedOutput: "(1 except 2)")
	}

	func testConditionalOperator() {
		performTest(input: "true ? \"foo\" : \"bar\"", expectedOutput: "(true ? \"foo\" : \"bar\")")
	}

	func testMalformedConditionalOperator() {
		performTest(input: "true ?", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedConditionalOperator_1() {
		performTest(input: "true ? \"foo\"", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedConditionalOperator_2() {
		performTest(input: "true ? \"foo\" :", expectedOutput: "PARSER_ERROR")
	}

	func testWhereOperator() {
		performTest(input: "1 where x : 2", expectedOutput: "(1 where x : 2)")
	}

	func testMapOperator() {
		performTest(input: "1 map x : 2", expectedOutput: "(1 map x : 2)")
	}

	func testContainsOperator() {
		performTest(input: "1 contains 2", expectedOutput: "(1 contains 2)")
	}

	func testLogicorOperator() {
		performTest(input: "1 || 2", expectedOutput: "(1 || 2)")
	}

	func testLgicandOperator() {
		performTest(input: "1 && 2", expectedOutput: "(1 && 2)")
	}

	func testEqualOperator() {
		performTest(input: "1 = 2", expectedOutput: "(1 == 2)")
	}

	func testEqualOperator_1() {
		performTest(input: "1 == 2", expectedOutput: "(1 == 2)")
	}

	func testNotequalOperator() {
		performTest(input: "1 != 2", expectedOutput: "(1 != 2)")
	}

	func testGreaterthanOperator() {
		performTest(input: "1 > 2", expectedOutput: "(1 > 2)")
	}

	func testGreaterorequalOperator() {
		performTest(input: "1 >= 2", expectedOutput: "(1 >= 2)")
	}

	func testLessthanOperator() {
		performTest(input: "1 < 2", expectedOutput: "(1 < 2)")
	}

	func testLessorequalOperator() {
		performTest(input: "1 <= 2", expectedOutput: "(1 <= 2)")
	}

	func testAdditionOperator() {
		performTest(input: "1 + 2", expectedOutput: "(1 + 2)")
	}

	func testSubtractionOperator() {
		performTest(input: "1 - 2", expectedOutput: "(1 - 2)")
	}

	func testMultiplicationOperator() {
		performTest(input: "1 * 2", expectedOutput: "(1 * 2)")
	}

	func testDivisionOperator() {
		performTest(input: "1 / 2", expectedOutput: "(1 / 2)")
	}

	func testModuloOperator() {
		performTest(input: "1 % 2", expectedOutput: "(1 % 2)")
	}

	func testCallOperator() {
		performTest(input: "a()", expectedOutput: "(a())")
	}

	func testCallOperator_1() {
		performTest(input: "a(1)", expectedOutput: "(a(1))")
	}

	func testCallOperator_2() {
		performTest(input: "a(1, true, $a, \"foo\")", expectedOutput: "(a(1, true, $a, \"foo\"))")
	}

	func testMalformedCallOperator() {
		performTest(input: "a(", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedCallOperator_1() {
		performTest(input: "a(,)", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedCallOperator_2() {
		performTest(input: "a(1,)", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedCallOperator_3() {
		performTest(input: "a(1;)", expectedOutput: "PARSER_ERROR")
	}

	func testAccessOperator() {
		performTest(input: "a.b", expectedOutput: "(a.b)")
	}

	func testAccessOperator_1() {
		performTest(input: "a.b.c", expectedOutput: "((a.b).c)")
	}

	func testAccessOperator_2() {
		performTest(input: "1.b", expectedOutput: "(1.b)")
	}

	func testAccessOperator_3() {
		performTest(input: "1.0.b", expectedOutput: "(1.b)")
	}

	func testMalformedAccessOperator() {
		performTest(input: "a.0", expectedOutput: "PARSER_ERROR")
	}

	func testMalformedAccessOperator_1() {
		performTest(input: "(a.)", expectedOutput: "PARSER_ERROR")
	}

	func testSubscriptOperator() {
		performTest(input: "a[1]", expectedOutput: "(a[1])")
	}

	func testMalformedSubscriptOperator() {
		performTest(input: "a[a b", expectedOutput: "PARSER_ERROR")
	}

	func testPrecedence() {
		performTest(input: "1 + 2 * 3", expectedOutput: "(1 + (2 * 3))")
	}

	func testPrecedence_1() {
		performTest(input: "(1 + 2) * 3", expectedOutput: "((1 + 2) * 3)")
	}

	func testPrecedence_2() {
		performTest(input: "1 + 2 - 3", expectedOutput: "((1 + 2) - 3)")
	}

	func testPrecedence_3() {
		performTest(input: "1 + (2 - 3)", expectedOutput: "(1 + (2 - 3))")
	}

	func testPrecedence_4() {
		performTest(input: "a * b + c * d % e - f", expectedOutput: "(((a * b) + ((c * d) % e)) - f)")
	}

	func testPrecedence_5() {
		performTest(input: "-a+b", expectedOutput: "((-a) + b)")
	}

	func testPrecedence_6() {
		performTest(input: "-a.b", expectedOutput: "(-(a.b))")
	}

	func testPrecedence_7() {
		performTest(input: "--a.b", expectedOutput: "(-(-(a.b)))")
	}

	func testPrecedence_8() {
		performTest(input: "--a % b", expectedOutput: "((-(-a)) % b)")
	}

	func testPrecedence_9() {
		performTest(input: "(-a).b", expectedOutput: "((-a).b)")
	}

	func testPrecedence_10() {
		performTest(input: "a.b.c", expectedOutput: "((a.b).c)")
	}

	func testPrecedence_11() {
		performTest(input: "a[1].m(2)", expectedOutput: "(((a[1]).m)(2))")
	}

	func testPrecedence_12() {
		performTest(input: "a[1 + 2]", expectedOutput: "(a[(1 + 2)])")
	}

	func testPrecedence_13() {
		performTest(input: "-[1][0]", expectedOutput: "(-([1][0]))")
	}

	func testPrecedence_14() {
		performTest(input: "[-1()]", expectedOutput: "[(-(1()))]")
	}

	func testPrecedence_15() {
		performTest(input: "[[a]()[b],[c]]", expectedOutput: "[(([a]())[b]), [c]]")
	}

	func testPrecedence_16() {
		performTest(input: "a + b contains c + d && e", expectedOutput: "(((a + b) contains (c + d)) && e)")
	}

	func testPrecedence_17() {
		performTest(input: "a ? b ? 1 : 2 : c ? 3 : 4", expectedOutput: "(a ? (b ? 1 : 2) : (c ? 3 : 4))")
	}

	func testManyOperators() {
		performTest(input: "a || b && c == d != e > f >= g < h <= i + j - k * l / m % n ? 1 : 2", expectedOutput: "((a || (b && ((c == d) != ((((e > f) >= g) < h) <= ((i + j) - (((k * l) / m) % n)))))) ? 1 : 2)")
	}

}
