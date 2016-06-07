// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


// subexpressions
extension Parser {

	internal func _parseLookup() throws -> ASTLookup {

		var elements: [ASTLookup.Element] = []

		elementsLoop: while true {
			let element: ASTLookup.Element

			switch currentToken {
			case .Lookup(let literal):
				element = .Single(literal.description)

			case .MultiLookup(let literal):
				element = .Multi(literal.description)

			default:
				break elementsLoop
			}

			try consumeCurrentToken()
			elements.append(element)
		}

		precondition(!elements.isEmpty)
		return ASTLookup(elements: elements)
	}
}

// literals
extension Parser {

	internal func _parseLiteral() throws -> ASTLiteral {

		switch currentToken {

		case .Int(let literal):
			try consumeCurrentToken()
			if let node = ASTNumberLiteral(fromString: literal.description) {
				return node
			} else {
				throw Parser.Error.ValueOutOfRange
			}

		case .Float(let literal):
			try consumeCurrentToken()
			if let node = ASTNumberLiteral(fromString: literal.description) {
				return node
			} else {
				throw Parser.Error.ValueOutOfRange
			}

		case .String(let literal):
			try consumeCurrentToken()
			return ASTStringLiteral(literal.description)

		case .True:
			try consumeCurrentToken()
			return ASTBoolLiteral(true)

		case .False:
			try consumeCurrentToken()
			return ASTBoolLiteral(false)

		case .Null:
			try consumeCurrentToken()
			return ASTNullLiteral.null

		case .LeftBracket:
			return try _parseContainerLiteral()

		default:
			preconditionFailure()
		}
	}

	internal func _parseContainerLiteral() throws -> ASTLiteral {

		try consumeCurrentToken()

		if let literal = try _parseEmptyContainerLiteral() {
			return literal
		}

		let firstElement = try parseExpression()
		switch currentToken {

		case .RightBracket:
			try consumeCurrentToken()
			return ASTListLiteral(elements: [firstElement])

		case .Comma:
			return try _parseListLiteral(firstElement: firstElement)

		case .Colon:
			return try _parseDictLiteral(firstKey: firstElement)

		default:
			throw unexpectedToken
		}
	}

	private func _parseEmptyContainerLiteral() throws -> ASTLiteral? {
		switch currentToken {

		case .RightBracket:
			try consumeCurrentToken()
			return ASTListLiteral(elements: [])

		case .Colon:
			try consumeCurrentToken()
			if case .RightBracket = currentToken {
				try consumeCurrentToken()
				return ASTDictLiteral(pairs: [])
			}
			throw unexpectedToken

		default:
			return nil
		}
	}
	
	private func _parseListLiteral(firstElement firstElement: ASTExpression) throws -> ASTListLiteral {

		var elements: [ASTExpression] = [ firstElement ]

		elementsLoop: while true {
			switch currentToken {

			case .Comma:
				try consumeCurrentToken()
				if case .RightBracket = currentToken {
					try consumeCurrentToken()
					break elementsLoop
				}

			case .RightBracket:
				try consumeCurrentToken()
				break elementsLoop

			default:
				throw unexpectedToken
			}

			elements.append(try parseExpression())
		}

		return ASTListLiteral(elements: elements)
	}

	private func _parseDictLiteral(firstKey firstKey: ASTExpression) throws -> ASTDictLiteral {

		var pairs: [(ASTExpression, ASTExpression)] = []

		var key = firstKey

		pairsLoop: while true {

			switch currentToken {

			case .Colon:
				try consumeCurrentToken()

			default:
				throw unexpectedToken
			}

			pairs.append((key, try parseExpression()))

			switch currentToken {

			case .Comma:
				try consumeCurrentToken()
				if case .RightBracket = currentToken {
					try consumeCurrentToken()
					break pairsLoop
				}

			case .RightBracket:
				try consumeCurrentToken()
				break pairsLoop

			default:
				throw unexpectedToken
			}

			key = try parseExpression()
		}

		return ASTDictLiteral(pairs: pairs)
	}
}
