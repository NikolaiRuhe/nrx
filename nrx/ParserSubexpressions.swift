// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


// subexpressions
extension Parser {

	internal func _parseLookup() throws -> ASTLookup {

		var elements: [LookupDescription.Element] = []

		elementsLoop: while true {
			let element: LookupDescription.Element

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

		let token = currentToken
		try consumeCurrentToken()

		switch token {

		case .Int(let literal):
			if let node = ASTNumberLiteral(fromString: literal.description) {
				return node
			} else {
				throw Parser.Error.ValueOutOfRange
			}

		case .Float(let literal):
			if let node = ASTNumberLiteral(fromString: literal.description) {
				return node
			} else {
				throw Parser.Error.ValueOutOfRange
			}

		case .String(let literal):
			return ASTStringLiteral(literal.description)

		case .True:
			return ASTBoolLiteral(true)

		case .False:
			return ASTBoolLiteral(false)

		case .Null:
			return ASTNullLiteral.instance

		case .LeftBracket:
			return try _parseContainerLiteral()

		default:
			preconditionFailure("_parseLiteral on bad token")
		}
	}

	internal func _parseContainerLiteral() throws -> ASTLiteral {

		if let literal = try _parseEmptyContainerLiteral() {
			return literal
		}

		let firstElement = try parseExpression()
		switch currentToken {

		case .RightBracket:
			try consume(.RightBracket)
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
			try consume(.RightBracket)
			return ASTListLiteral(elements: [])

		case .Colon:
			try consume(.Colon)
			try consume(.RightBracket)
			return ASTDictLiteral(pairs: [])

		default:
			return nil
		}
	}
	
	private func _parseListLiteral(firstElement firstElement: ASTExpression) throws -> ASTListLiteral {

		var elements: [ASTExpression] = [ firstElement ]

		elementsLoop: while true {
			switch currentToken {

			case .Comma:
				try consume(.Comma)
				if case .RightBracket = currentToken {
					try consume(.RightBracket)
					break elementsLoop
				}

			case .RightBracket:
				try consume(.RightBracket)
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

			try consume(.Colon)

			pairs.append((key, try parseExpression()))

			switch currentToken {

			case .Comma:
				try consume(.Comma)
				if case .RightBracket = currentToken {
					try consume(.RightBracket)
					break pairsLoop
				}

			case .RightBracket:
				try consume(.RightBracket)
				break pairsLoop

			default:
				throw unexpectedToken
			}

			key = try parseExpression()
		}

		return ASTDictLiteral(pairs: pairs)
	}
}
