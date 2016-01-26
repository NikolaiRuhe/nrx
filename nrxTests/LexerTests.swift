// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class LexerTests: XCTestCase {

	func testEmptyLexer() {
		var sut = Lexer(source: "")
		XCTAssertNil(sut.next(), "lexer not empty")
	}

	func testLexerError() {
		var sut = Lexer(source: "#")
		XCTAssertEqual(sut.next()?.testNotation, "LEXER_ERROR", "expected lexer error")
	}

	func testSimpleToken() {
		var sut = Lexer(source: ".")
		XCTAssertEqual(sut.next()?.testNotation, "Dot", "expected Dot token")
		XCTAssertNil(sut.next(), "lexer not empty")
	}

	func testBadUTF8InStringLiteral() {
		var sut = Lexer(zeroTerminatedUTF8FragmentBuffer: [34, 0xf0, 34, 0])
		XCTAssertEqual(sut.next()?.testNotation, "LEXER_ERROR", "expected lexer error")
	}

	func performPerformanceTest(input input: String, file: String = __FILE__, line: UInt = __LINE__) {

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

	func performTest(input input: String, expectedOutput: String, file: String = __FILE__, line: UInt = __LINE__) {

		var sut = Lexer(source: input)

		var tokens : [Token] = []
		tokenLoop: while true {
			let token = sut.scanToken()
			switch token {
			case .AtEnd:
				break tokenLoop
			case .LexerError:
				if expectedOutput == "LEXER_ERROR" {
					return
				}
				XCTFail("unexpected lexer error", file: file, line: line)
				return
			default:
				tokens.append(token)
			}
		}

		let result = tokens.map {$0.testNotation}.joinWithSeparator(" ")
		if result != expectedOutput {
			XCTFail("\(name): \(result) != \(expectedOutput)", file: file, line: line)
		}
	}
}

// --------- generated tests below this line: do not edit ---------

extension LexerTests {

	func testDot() {
		performTest(input: ".", expectedOutput: "Dot")
	}

	func testNot() {
		performTest(input: "!", expectedOutput: "Not")
	}

	func testEqual() {
		performTest(input: "=", expectedOutput: "Equal")
	}

	func testEqual2() {
		performTest(input: "==", expectedOutput: "Equal")
	}

	func testNotequal() {
		performTest(input: "!=", expectedOutput: "NotEqual")
	}

	func testGreaterOrEqual() {
		performTest(input: ">=", expectedOutput: "GreaterOrEqual")
	}

	func testGreater() {
		performTest(input: ">", expectedOutput: "Greater")
	}

	func testLessOrEqual() {
		performTest(input: "<=", expectedOutput: "LessOrEqual")
	}

	func testLess() {
		performTest(input: "<", expectedOutput: "Less")
	}

	func testAssign() {
		performTest(input: ":=", expectedOutput: "Assign")
	}

	func testMinus() {
		performTest(input: "-", expectedOutput: "Minus")
	}

	func testPlus() {
		performTest(input: "+", expectedOutput: "Plus")
	}

	func testComma() {
		performTest(input: ",", expectedOutput: "Comma")
	}

	func testStar() {
		performTest(input: "*", expectedOutput: "Star")
	}

	func testDivis() {
		performTest(input: "/", expectedOutput: "Divis")
	}

	func testModulo() {
		performTest(input: "%", expectedOutput: "Modulo")
	}

	func testLeftParenthesis() {
		performTest(input: "(", expectedOutput: "LeftParen")
	}

	func testRightParenthesis() {
		performTest(input: ")", expectedOutput: "RightParen")
	}

	func testSemicolon() {
		performTest(input: ";", expectedOutput: "Semicolon")
	}

	func testLeftBrace() {
		performTest(input: "{", expectedOutput: "LeftBrace")
	}

	func testRightBrace() {
		performTest(input: "}", expectedOutput: "RightBrace")
	}

	func testLeftBracket() {
		performTest(input: "[", expectedOutput: "LeftBracket")
	}

	func testRightBracket() {
		performTest(input: "]", expectedOutput: "RightBracket")
	}

	func testQuestionmark() {
		performTest(input: "?", expectedOutput: "Questionmark")
	}

	func testColon() {
		performTest(input: ":", expectedOutput: "Colon")
	}

	func testAnd() {
		performTest(input: "&&", expectedOutput: "And")
	}

	func testOr() {
		performTest(input: "||", expectedOutput: "Or")
	}

	func testAndKeyword() {
		performTest(input: "and", expectedOutput: "And")
	}

	func testAssertKeyword() {
		performTest(input: "assert", expectedOutput: "Assert")
	}

	func testBreakKeyword() {
		performTest(input: "break", expectedOutput: "Break")
	}

	func testCatchKeyword() {
		performTest(input: "catch", expectedOutput: "Catch")
	}

	func testContainsKeyword() {
		performTest(input: "contains", expectedOutput: "Contains")
	}

	func testContinueKeyword() {
		performTest(input: "continue", expectedOutput: "Continue")
	}

	func testElseKeyword() {
		performTest(input: "else", expectedOutput: "Else")
	}

	func testErrorKeyword() {
		performTest(input: "error", expectedOutput: "Error")
	}

	func testExceptKeyword() {
		performTest(input: "except", expectedOutput: "Except")
	}

	func testFalseKeyword() {
		performTest(input: "false", expectedOutput: "False")
	}

	func testForKeyword() {
		performTest(input: "for", expectedOutput: "For")
	}

	func testIfKeyword() {
		performTest(input: "if", expectedOutput: "If")
	}

	func testInKeyword() {
		performTest(input: "in", expectedOutput: "In")
	}

	func testMapKeyword() {
		performTest(input: "map", expectedOutput: "Map")
	}

	func testNullKeyword() {
		performTest(input: "NULL", expectedOutput: "Null")
	}

	func testOrKeyword() {
		performTest(input: "or", expectedOutput: "Or")
	}

	func testPrintKeyword() {
		performTest(input: "print", expectedOutput: "Print")
	}

	func testReturnKeyword() {
		performTest(input: "return", expectedOutput: "Return")
	}

	func testTrueKeyword() {
		performTest(input: "true", expectedOutput: "True")
	}

	func testTryKeyword() {
		performTest(input: "try", expectedOutput: "Try")
	}

	func testWhereKeyword() {
		performTest(input: "where", expectedOutput: "Where")
	}

	func testWhileKeyword() {
		performTest(input: "while", expectedOutput: "While")
	}

	func testEmptySource() {
		performTest(input: "", expectedOutput: "")
	}

	func testSimpleSequence() {
		performTest(input: "...", expectedOutput: "Dot Dot Dot")
	}

	func testSkipWhitespace() {
		performTest(input: " \t\n\r. \t\n\r.", expectedOutput: "Dot Dot")
	}

	func testSingleLineComment() {
		performTest(input: "// C++ comment\n.", expectedOutput: "Dot")
	}

	func testMultiLineComment() {
		performTest(input: "/* C comment */.", expectedOutput: "Dot")
	}

	func testUnterminatedCComment() {
		performTest(input: "/*", expectedOutput: "LEXER_ERROR")
	}

	func testUnterminatedCComment2() {
		performTest(input: "/*/", expectedOutput: "LEXER_ERROR")
	}

	func testCCommentPattern() {
		performTest(input: "/*/*/*", expectedOutput: "Star")
	}

	func testShortestCComment() {
		performTest(input: "/**/.", expectedOutput: "Dot")
	}

	func testSingleStarInCComment() {
		performTest(input: "/***/.", expectedOutput: "Dot")
	}

	func testNullCharInCComment() {
		performTest(input: "/*/0*/.", expectedOutput: "Dot")
	}

	func testSingleLineCommentWithCEnding() {
		performTest(input: "// C++*/\n.", expectedOutput: "Dot")
	}

	func testSingleAndMultiLineComment() {
		performTest(input: "// C++\n/* C */.", expectedOutput: "Dot")
	}

	func testSingleLetterIdentifier() {
		performTest(input: "i", expectedOutput: "Ident(i)")
	}

	func testMultiLetterIdentifier() {
		performTest(input: "self", expectedOutput: "Ident(self)")
	}

	func testIdentifierSequence() {
		performTest(input: "one, two and three", expectedOutput: "Ident(one) Comma Ident(two) And Ident(three)")
	}

	func testIdentifierWithLeadingUnderscore() {
		performTest(input: "_a", expectedOutput: "Ident(_a)")
	}

	func testIdentifierWithTrailingUnderscore() {
		performTest(input: "a_", expectedOutput: "Ident(a_)")
	}

	func testIdentifierSequence2() {
		performTest(input: "_ a", expectedOutput: "Ident(_) Ident(a)")
	}

	func testNotAnIdentifier() {
		performTest(input: "0_", expectedOutput: "LEXER_ERROR")
	}

	func testSingleLookup() {
		performTest(input: "$abc", expectedOutput: "Lookup(abc)")
	}

	func testSingleLookupWithProp() {
		performTest(input: "$ab.c", expectedOutput: "Lookup(ab) Dot Ident(c)")
	}

	func testMultiLookup() {
		performTest(input: "$$_0", expectedOutput: "MultiLookup(_0)")
	}

	func testLookupChain() {
		performTest(input: "$a$$b$c$$d", expectedOutput: "Lookup(a) MultiLookup(b) Lookup(c) MultiLookup(d)")
	}

	func testEmptyLookup() {
		performTest(input: "$", expectedOutput: "LEXER_ERROR")
	}

	func testEmptyMultiLookup() {
		performTest(input: "$$", expectedOutput: "LEXER_ERROR")
	}

	func testBadLookupStartChar() {
		performTest(input: "$0", expectedOutput: "LEXER_ERROR")
	}

	func testBadMultiLookupStartChar() {
		performTest(input: "$$0", expectedOutput: "LEXER_ERROR")
	}

	func testInteger0() {
		performTest(input: "0", expectedOutput: "Int(0)")
	}

	func testInteger1() {
		performTest(input: "1", expectedOutput: "Int(1)")
	}

	func testInteger01() {
		performTest(input: "01", expectedOutput: "Int(1)")
	}

	func testInteger42() {
		performTest(input: "42", expectedOutput: "Int(42)")
	}

	func testIntegerSequence42() {
		performTest(input: "4 2", expectedOutput: "Int(4) Int(2)")
	}

	func testIntegerMinus123() {
		performTest(input: "-123", expectedOutput: "Minus Int(123)")
	}

	func testBadInteger() {
		performTest(input: "1a", expectedOutput: "LEXER_ERROR")
	}

	func testIntegerWithProperty() {
		performTest(input: "1.a", expectedOutput: "Int(1) Dot Ident(a)")
	}

	func testFloatZero() {
		performTest(input: "0.0", expectedOutput: "Float(0)")
	}

	func testFloatAltZeroA() {
		performTest(input: "0.", expectedOutput: "Float(0)")
	}

	func testFloatAltZeroB() {
		performTest(input: ".0", expectedOutput: "Float(0)")
	}

	func testFloatAltZeroC() {
		performTest(input: "00.", expectedOutput: "Float(0)")
	}

	func testFloatAltZeroD() {
		performTest(input: ".00", expectedOutput: "Float(0)")
	}

	func testFloatAltZeroE() {
		performTest(input: "00.00", expectedOutput: "Float(0)")
	}

	func testFloat42() {
		performTest(input: "42.", expectedOutput: "Float(42)")
	}

	func testFloatSkipRedundantZeros() {
		performTest(input: "010.010", expectedOutput: "Float(10.01)")
	}

	func testFloatSequence42() {
		performTest(input: "4. .2", expectedOutput: "Float(4) Float(.2)")
	}

	func testFloatMinus123() {
		performTest(input: "-123.", expectedOutput: "Minus Float(123)")
	}

	func testBadFloat2() {
		performTest(input: ".1a", expectedOutput: "LEXER_ERROR")
	}

	func testBadFloat3() {
		performTest(input: "1.1a", expectedOutput: "LEXER_ERROR")
	}

	func testFloatWithProperty() {
		performTest(input: "1.1.a", expectedOutput: "Float(1.1) Dot Ident(a)")
	}

	func testDoubleQuotedStringEmpty() {
		performTest(input: "\"\"", expectedOutput: "String()")
	}

	func testDoubleQuotedStringSimple() {
		performTest(input: "\"...\"", expectedOutput: "String(...)")
	}

	func testDoubleQuotedStringHello() {
		performTest(input: "\"Hello, World!\"", expectedOutput: "String(Hello, World!)")
	}

	func testDoubleQuotedStringEscapedQuote() {
		performTest(input: "\"\\\"\"", expectedOutput: "String(\")")
	}

	func testDoubleQuotedStringEscapedBackslash() {
		performTest(input: "\"\\\\\"", expectedOutput: "String(\\)")
	}

	func testDoubleQuotedStringEscapedNewline() {
		performTest(input: "\"\\n\"", expectedOutput: "String(\n)")
	}

	func testDoubleQuotedStringWithNulChar() {
		performTest(input: "\"\0\"", expectedOutput: "String(\0)")
	}

	func testDoubleQuotedStringUnterminated() {
		performTest(input: "\"", expectedOutput: "LEXER_ERROR")
	}

	func testDoubleQuotedStringUntermEsc() {
		performTest(input: "\"\\", expectedOutput: "LEXER_ERROR")
	}

	func testDoubleQuotedStringUntermPostEsc() {
		performTest(input: "\"\\\"", expectedOutput: "LEXER_ERROR")
	}

	func testDoubleQuotedStringUnknownEscape() {
		performTest(input: "\"\\r\"", expectedOutput: "LEXER_ERROR")
	}

	func testDoubleQuotedStringBadQuoteEscape() {
		performTest(input: "\"\\'\"", expectedOutput: "LEXER_ERROR")
	}

	func testDoubleQuotedStringNonBmpChar() {
		performTest(input: "\"🍉\"", expectedOutput: "String(🍉)")
	}

	func testSingleQuotedStringEmpty() {
		performTest(input: "''", expectedOutput: "String()")
	}

	func testSingleQuotedStringSimple() {
		performTest(input: "'...'", expectedOutput: "String(...)")
	}

	func testSingleQuotedStringHello() {
		performTest(input: "'Hello, World!'", expectedOutput: "String(Hello, World!)")
	}

	func testSingleQuotedStringEscapedQuote() {
		performTest(input: "'\\''", expectedOutput: "String(')")
	}

	func testSingleQuotedStringEscapedBackslash() {
		performTest(input: "'\\\\'", expectedOutput: "String(\\)")
	}

	func testSingleQuotedStringEscapedNewline() {
		performTest(input: "'\\n'", expectedOutput: "String(\n)")
	}

	func testSingleQuotedStringWithNulChar() {
		performTest(input: "'\0'", expectedOutput: "String(\0)")
	}

	func testSingleQuotedStringUnterminated() {
		performTest(input: "'", expectedOutput: "LEXER_ERROR")
	}

	func testSingleQuotedStringUntermEsc() {
		performTest(input: "'\\", expectedOutput: "LEXER_ERROR")
	}

	func testSingleQuotedStringUntermPostEsc() {
		performTest(input: "'\\'", expectedOutput: "LEXER_ERROR")
	}

	func testSingleQuotedStringUnknownEscape() {
		performTest(input: "'\\r'", expectedOutput: "LEXER_ERROR")
	}

	func testSingleQuotedStringBadQuoteEscape() {
		performTest(input: "'\\\"'", expectedOutput: "LEXER_ERROR")
	}

	func testHalfOr() {
		performTest(input: "|", expectedOutput: "LEXER_ERROR")
	}

	func testTripleOr() {
		performTest(input: "|||", expectedOutput: "LEXER_ERROR")
	}

	func testHalfAnd() {
		performTest(input: "&", expectedOutput: "LEXER_ERROR")
	}

	func testTripleAnd() {
		performTest(input: "&&&", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharNull() {
		performTest(input: "\0", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharBackslash() {
		performTest(input: "\\", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharNumberSign() {
		performTest(input: "#", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharAt() {
		performTest(input: "@", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharCircumflex() {
		performTest(input: "^", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharBacktick() {
		performTest(input: "`", expectedOutput: "LEXER_ERROR")
	}

	func testUnknownCharTilde() {
		performTest(input: "~", expectedOutput: "LEXER_ERROR")
	}

	func testPerformance() {
		performTest(input: "[ \"1\", \"2\", \"3\", \"Hello, World!\", \"1️⃣\" ] ((map x : NUMBER(x)) where i: i % 2 == 1).count", expectedOutput: "LeftBracket String(1) Comma String(2) Comma String(3) Comma String(Hello, World!) Comma String(1️⃣) RightBracket LeftParen LeftParen Map Ident(x) Colon Ident(NUMBER) LeftParen Ident(x) RightParen RightParen Where Ident(i) Colon Ident(i) Modulo Int(2) Equal Int(1) RightParen Dot Ident(count)")
	}

}
