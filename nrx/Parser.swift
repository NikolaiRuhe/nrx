// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation

/// The `Parser` transforms a stream of `Token`s to the abstract syntax tree (AST)
/// representation.
///
/// It checks syntax of the source code and returns an error if the input does not conform.
///	It also determines the order in which expressions evaluate their arguments.
internal final class Parser {

	enum Error: ErrorType {
		case InvalidToken
		case ValueOutOfRange
		case UnexpectedToken
		case UnexpectedEnd
	}

	var currentToken: Token
	private var lexer: Lexer

	var isAtEnd: Bool {
		switch currentToken {
		case .AtEnd: return true
		default:     return false
		}
	}

	init(lexer: Lexer) {
		self.lexer = lexer
		currentToken = self.lexer.scanToken()
	}

	func consumeCurrentToken() throws {
		switch currentToken {
		case .AtEnd, .LexerError:
			preconditionFailure("implementation error: the parser should have caught this")
		default: break
		}
		currentToken = self.lexer.scanToken()
	}

	func consumeIdentifier() throws -> String {
		guard case .Identifier (let name) = currentToken else {
			throw unexpectedToken
		}
		try consumeCurrentToken()
		return name.description
	}

	func consume(token: Token) throws {
		guard token == currentToken else {
			throw unexpectedToken
		}
		try consumeCurrentToken()
	}

	var unexpectedToken: Error {
		switch currentToken {
		case .AtEnd:         return Error.UnexpectedEnd
		case .LexerError(_): return Error.InvalidToken
		default:             return Error.UnexpectedToken
		}
	}

	func parseProgram() throws -> ASTBlock {
		var statements: [ASTStatement] = []
		while !self.isAtEnd {
			statements.append(try parseStatement())
		}
		return ASTBlock(statements: statements)
	}
}
