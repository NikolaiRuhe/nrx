// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


extension Parser {
	func parseStatement() throws -> ASTStatement {

		switch currentToken {

		case .Semicolon: try consume(.Semicolon); return ASTNoOp.instance
		case .Continue:  try consume(.Continue);  try consume(.Semicolon); return ASTContinue.instance
		case .Break:     try consume(.Break);     try consume(.Semicolon); return ASTBreak.instance
		case .Return:    return try _parseReturn()
		case .LeftBrace: return try _parseBlock()
		case .Print:     return try _parsePrint()
		case .Error:     return try _parseError()
		case .While:     return try _parseWhile()
		case .For:       return try _parseFor()
		case .If:        return try _parseIfElse()
		case .Try:       return try _parseTry()

		default:
			// The remaining statements are:
			//   - variable assigment
			//   - property assignment
			//   - function call
			//   - function definition
			// They have a syntax that starts with an expression, so we use this expression
			// to built the statement nodes.
			let expression = try parseExpression()

			switch currentToken {
			case .Assign:    return try _parseAssignment(expression)
			case .Semicolon: return try _parseFunctionCall(expression)
			case .LeftBrace: return try _parseFunctionDefinition(expression)
			default: throw unexpectedToken
			}
		}
	}
}

private extension Parser {

	private func _parseOptionalExpression() throws -> ASTExpression? {
		if case .Semicolon = currentToken {
			try consume(.Semicolon)
			return nil
		}
		let expression = try parseExpression()
		try consume(.Semicolon)
		return expression
	}

	private func _parseParenthesizedExpression() throws -> ASTExpression {
		try consume(.LeftParen)
		let expression = try parseExpression()
		try consume(.RightParen)
		return expression
	}

	private func _parsePrint() throws -> ASTPrint {
		try consume(.Print)
		return ASTPrint(expression: try _parseOptionalExpression() ?? ASTStringLiteral(""))
	}

	private func _parseAssert() throws -> ASTAssert {
		try consume(.Assert)
		let expression = try parseExpression()
		try consume(.Semicolon)
		return ASTAssert(expression: expression)
	}

	private func _parseError() throws -> ASTError {
		try consume(.Error)
		let expression = try parseExpression()
		try consume(.Semicolon)
		return ASTError(expression: expression)
	}

	private func _parseReturn() throws -> ASTReturn {
		try consume(.Return)
		return ASTReturn(expression: try _parseOptionalExpression() ?? ASTNullLiteral.instance)
	}

	private func _parseWhile() throws -> ASTWhile {
		try consume(.While)
		let expression = try _parseParenthesizedExpression()
		let body = try parseStatement()
		return ASTWhile(condition: expression, body: body)
	}

	private func _parseFor() throws -> ASTForIn {
		try consume(.For)
		try consume(.LeftParen)
		let variable = try consumeIdentifier()
		try consume(.In)
		let iterable = try parseExpression()
		try consume(.RightParen)
		let body = try parseStatement()
		return ASTForIn(variable: variable, iterable: iterable, body: body)
	}

	private func _parseIfElse() throws -> ASTIfElse {
		try consume(.If)
		let expression = try _parseParenthesizedExpression()
		let statement = try parseStatement()

		let elseStatement: ASTStatement
		if case .Else = currentToken {
			try consume(.Else)
			elseStatement = try parseStatement()
		} else {
			elseStatement = ASTNoOp.instance
		}
		return ASTIfElse(condition: expression, statement: statement, elseStatement: elseStatement)
	}

	private func _parseTry() throws -> ASTTryCatch {
		try consume(.Try)
		let body = try _parseBlock()
		try consume(.Catch)
		try consume(.LeftParen)
		let variable = try consumeIdentifier()
		try consume(.RightParen)
		let catchBlock = try _parseBlock()
		return ASTTryCatch(body: body, variable: variable, catchBlock: catchBlock)
	}

	private func _parseAssignment(lhs: ASTExpression) throws -> ASTStatement {
		try consume(.Assign)

		switch lhs {
		case let access as ASTAccess:
			let rhs = try parseExpression()
			try consume(.Semicolon)
			return ASTPropertyAssignment(lhs: access._object, name: access._name, rhs: rhs)
		case let identifier as ASTIdentifier:
			let rhs = try parseExpression()
			try consume(.Semicolon)
			return ASTAssignment(name: identifier._name, rhs: rhs)
		default:
			throw unexpectedToken
		}
	}

	private func _parseFunctionCall(expression: ASTExpression) throws -> ASTStatement {
		try consume(.Semicolon)
		guard let callExpression = expression as? ASTCall else {
			throw unexpectedToken
		}
		return ASTCallStatement(callExpression: callExpression)
	}

	private func _parseFunctionDefinition(expression: ASTExpression) throws -> ASTStatement {
		// A function definition has the following form: `name(arg1, arg2) { statements; }`
		// The part before the body has already been parsed as an expression. It has the same
		// syntax as a call. Here we take this call expression apart and use the parts for the
		// function definition node.
		guard let call = expression as? ASTCall else {
			throw unexpectedToken
		}
		guard let identifier = call._callable as? ASTIdentifier else {
			throw unexpectedToken
		}
		let parameters = try call._arguments.map {
			(argument: ASTExpression) -> String in
			guard let parameter = argument as? ASTIdentifier else {
				throw unexpectedToken
			}
			return parameter._name
		}
		let body = try _parseBlock()
		return ASTFunctionDefinitionStatement(name: identifier._name, parameterNames: parameters, body: body)
	}

	func _parseBlock() throws -> ASTBlock {
		try consume(.LeftBrace)
		var statements: [ASTStatement] = []
		while true {
			if case .RightBrace = currentToken {
				try consume(.RightBrace)
				return ASTBlock(statements: statements)
			}
			statements.append(try parseStatement())
		}
	}
}
