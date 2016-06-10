// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


extension Parser {

	/// Parses an expression and returns it as an AST node.
	///
	/// This method parses a whole expression, respecting precedence and
	/// associativity. It combines operators on the go using precedence
	/// climbing.
	///
	/// - seealso: [wikipedia article](https://en.wikipedia.org/wiki/Operator-precedence_parser) on precedence climbing

	internal func parseExpression() throws -> ASTExpression {
		return try _parseExpression(minPrecedence: .Lowest)
	}
}

// MARK: - Private helper functions

private extension Parser {

	private func _parseExpression(minPrecedence minPrecedence: Precedence) throws -> ASTExpression {
		let primary = try _parsePrimaryExpression()
		return try _parseCombinedExpression(lhs: primary, minPrecedence: minPrecedence)
	}

	func _parsePrimaryExpression() throws -> ASTExpression {

		switch currentToken {

		case .Lookup, .MultiLookup:
			return try _parseLookup()

		case .Identifier:
			return ASTIdentifier(name: try expectIdentifier())

		case .Int, .Float, .String, .True, .False, .Null, .LeftBracket:
			return try _parseLiteral()

		case .Minus:
			try consumeCurrentToken()
			let expression = try _parseExpression(minPrecedence: .Prefix)
			return ASTArithmeticNegation(operand: expression)

		case .Not:
			try consumeCurrentToken()
			let expression = try _parseExpression(minPrecedence: .Prefix)
			return ASTLogicalNegation(operand: expression)

		case .LeftParen:
			try consumeCurrentToken()
			let expression = try parseExpression()
			if case .RightParen = currentToken {
				try consumeCurrentToken()
				return expression
			}
			throw unexpectedToken

		default:
			throw unexpectedToken
		}
	}

	// This is the core precedence climbing expression parser.
	func _parseCombinedExpression(lhs originalExpression: ASTExpression, minPrecedence: Precedence) throws -> ASTExpression {

		var accumulatedLHS = originalExpression

		while let leftOperator = Operator(fromToken: currentToken)
			where leftOperator.precedence >= minPrecedence {
				try consumeCurrentToken()

				switch leftOperator {
				case .Conditional:
					accumulatedLHS = try _parseConditionalOperator(condition: accumulatedLHS)
				case .Where:
					accumulatedLHS = try _parseWhereOperator(lhs: accumulatedLHS)
				case .Map:
					accumulatedLHS = try _parseMapOperator(lhs: accumulatedLHS)
				case .Except, .Contains, .LogicOr, .LogicAnd, .Equal, .NotEqual, .GreaterThan, .GreaterOrEqual, .LessThan, .LessOrEqual, .Addition, .Subtraction, .Multiplication, .Division, .Modulo:
					accumulatedLHS = try _parseBinaryOperator(leftOperator: leftOperator, lhs: accumulatedLHS)
				case .Call:
					accumulatedLHS = try _parseCallOperator(callable: accumulatedLHS)
				case .Access:
					accumulatedLHS = try _parseAccessOperator(object: accumulatedLHS)
				case .Subscript:
					accumulatedLHS = try _parseSubscriptOperator(container: accumulatedLHS)
				}
		}
	
		return accumulatedLHS
	}

	func _parseConditionalOperator(condition condition: ASTExpression) throws -> ASTExpression {
		let positiveExpression = try parseExpression()
		try expectColon()
		let negativeExpression = try _parseExpression(minPrecedence: .Conditional)
		return ASTConditionalOperator(condition: condition, positiveExpression: positiveExpression, negativeExpression: negativeExpression)
	}

	func _parseWhereOperator(lhs lhs: ASTExpression) throws -> ASTExpression {
		let identifier = try expectIdentifier()
		try expectColon()
		let predicateExpression = try _parseExpression(minPrecedence: .Functional)
		return ASTWhereOperator(iterableExpression: lhs, identifier: identifier, predicateExpression: predicateExpression)
	}

	func _parseMapOperator(lhs lhs: ASTExpression) throws -> ASTExpression {
		let identifier = try expectIdentifier()
		try expectColon()
		let transformExpression = try _parseExpression(minPrecedence: .Functional)
		return ASTMapOperator(iterableExpression: lhs, identifier: identifier, transformExpression: transformExpression)
	}

	func _parseBinaryOperator(leftOperator leftOperator: Operator, lhs: ASTExpression) throws -> ASTExpression {
		var accumulatedRHS = try _parsePrimaryExpression()

		while let rightOperator = Operator(fromToken: currentToken)
			where rightOperator.bindsStrongerThan(leftOperator: leftOperator) {

				accumulatedRHS = try _parseCombinedExpression(lhs: accumulatedRHS, minPrecedence: rightOperator.precedence)
		}

		guard let nodeType = leftOperator.binaryOperatorNodeType else {
			preconditionFailure()
		}
		return nodeType.init(lhs: lhs, rhs: accumulatedRHS)
	}

	func _parseCallOperator(callable callable: ASTExpression) throws -> ASTExpression {
		var arguments: [ASTExpression] = []

		switch currentToken {
		case .RightParen:
			try consumeCurrentToken()
			return ASTCall(callable: callable, arguments: [])

		default:
			break
		}

		argumentsLoop: while true {

			arguments.append(try parseExpression())

			switch currentToken {
			case .Comma:
				try consumeCurrentToken()

			case .RightParen:
				try consumeCurrentToken()
				break argumentsLoop

			default:
				throw unexpectedToken
			}
		}

		return ASTCall(callable: callable, arguments: arguments)
	}

	func _parseAccessOperator(object object: ASTExpression) throws -> ASTExpression {
		let identifier = try expectIdentifier()
		return ASTAccess(object: object, name: identifier)
	}

	func _parseSubscriptOperator(container container: ASTExpression) throws -> ASTExpression {
		let indexExpression = try parseExpression()
		try expectRightBracket()
		return ASTSubscript(container: container, key: indexExpression)
	}
}


// MARK: - Private helper types

private extension Parser {

	enum Associativity {
		case Left
		case Right
	}

	enum Precedence: Int, Comparable {
		case Lowest
		case Exceptional
		case Conditional
		case Functional
		case LogicalOr
		case LogicalAnd
		case Contains
		case Equality
		case Relational
		case Additive
		case Multiplicative
		case Prefix
		case Member
	}

	enum Operator {

		case Except
		case Conditional
		case Where
		case Map
		case Contains
		case LogicOr
		case LogicAnd
		case Equal
		case NotEqual
		case GreaterThan
		case GreaterOrEqual
		case LessThan
		case LessOrEqual
		case Addition
		case Subtraction
		case Multiplication
		case Division
		case Modulo
		case Call
		case Access
		case Subscript

		init?(fromToken token: Token) {
			switch token {
			case .Except:          self = .Except
			case .Questionmark:    self = .Conditional
			case .Where:           self = .Where
			case .Map:             self = .Map
			case .Contains:        self = .Contains
			case .Or:              self = .LogicOr
			case .And:             self = .LogicAnd
			case .NotEqual:        self = .NotEqual
			case .Equal:           self = .Equal
			case .Greater:         self = .GreaterThan
			case .GreaterOrEqual:  self = .GreaterOrEqual
			case .Less:            self = .LessThan
			case .LessOrEqual:     self = .LessOrEqual
			case .Plus:            self = .Addition
			case .Minus:           self = .Subtraction
			case .Star:            self = .Multiplication
			case .Divis:           self = .Division
			case .Modulo:          self = .Modulo
			case .LeftParen:       self = .Call
			case .Dot:             self = .Access
			case .LeftBracket:     self = .Subscript
			default:               return nil
			}
		}

		var associativity: Associativity {
			// The only right associative operators are unary not and unary minus.
			// They are not parsed in _parsePrimaryExpression, so they are not listed here.
			return .Left
		}

		var precedence: Precedence {
			switch self {
			case .Except:                             return .Exceptional
			case .Conditional:                        return .Conditional
			case .Where, .Map:                        return .Functional
			case .Contains:                           return .Contains
			case .LogicOr:                            return .LogicalOr
			case .LogicAnd:                           return .LogicalAnd
			case .Equal, .NotEqual:                   return .Equality
			case .GreaterThan, .GreaterOrEqual, .LessThan, .LessOrEqual:
				                                      return .Relational
			case .Addition, .Subtraction:             return .Additive
			case .Multiplication, .Division, .Modulo: return .Multiplicative
			case .Call, .Access, .Subscript:          return .Member
			}
		}

		func bindsStrongerThan(leftOperator leftOperator: Operator) -> Bool {
			if (self.precedence > leftOperator.precedence) {
				return true
			}
			return self.associativity == .Right && self.precedence == leftOperator.precedence
		}

		var binaryOperatorNodeType: ASTBinaryOperator.Type? {
			switch self {
			case .Except:           return ASTExcept.self
			case .Contains:         return ASTContains.self
			case .LogicOr:          return ASTLogicOr.self
			case .LogicAnd:         return ASTLogicAnd.self
			case .Equal:            return ASTEqual.self
			case .NotEqual:         return ASTNotEqual.self
			case .GreaterThan:      return ASTGreaterThan.self
			case .GreaterOrEqual:   return ASTGreaterOrEqual.self
			case .LessThan:         return ASTLessThan.self
			case .LessOrEqual:      return ASTLessOrEqual.self
			case .Addition:         return ASTAddition.self
			case .Subtraction:      return ASTSubtraction.self
			case .Multiplication:   return ASTMultiplication.self
			case .Division:         return ASTDivision.self
			case .Modulo:           return ASTModulo.self
			default:                return nil
			}
		}
	}
}

private func ==(lhs: Parser.Precedence, rhs: Parser.Precedence) -> Bool {
	return lhs.rawValue == rhs.rawValue
}

private func <(lhs: Parser.Precedence, rhs: Parser.Precedence) -> Bool {
	return lhs.rawValue < rhs.rawValue
}
