// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation
@testable import nrx


/// TestNotation is used in unit tests to convert token streams, AST trees or evaluation
/// results to a well defined string representation. In each test the string representation
/// is then compared with an expected output.

protocol TestNotation {
	var testNotation: String { get }
}


// MARK: - Lexer Tests

extension Token : TestNotation {
	var testNotation: Swift.String {
		switch self {
		case let .Identifier    (value):  return "Ident(\(value))"
		case let .Int           (value):  return "Int(\(value))"
		case let .Float         (value):  return "Float(\(value))"
		case let .String        (value):  return "String(\(value))"
		case let .Lookup        (value):  return "Lookup(\(value))"
		case let .MultiLookup   (value):  return "MultiLookup(\(value))"
		case     .LexerError:             return "LEXER_ERROR"
		default:                          return "\(self)"
		}
	}
}


// MARK: - Parser Tests

extension ASTNode : TestNotation {

	// NOTE: As of Swift 2.2 it's not possible to override declarations in extensions. So we have
	// to resort to "poor man's dispatch" instead of just overriding `testNotation` in ASTNode
	// subclasses.
	var testNotation: String {
		switch self {

		case let node as ASTArithmeticNegation:  return node._testNotation
		case let node as ASTLogicalNegation:     return node._testNotation
		case let node as ASTExcept:              return node._testNotation(forOperator: "except")
		case let node as ASTContains:            return node._testNotation(forOperator: "contains")
		case let node as ASTLogicOr:             return node._testNotation(forOperator: "||")
		case let node as ASTLogicAnd:            return node._testNotation(forOperator: "&&")
		case let node as ASTEqual:               return node._testNotation(forOperator: "==")
		case let node as ASTNotEqual:            return node._testNotation(forOperator: "!=")
		case let node as ASTGreaterThan:         return node._testNotation(forOperator: ">")
		case let node as ASTGreaterOrEqual:      return node._testNotation(forOperator: ">=")
		case let node as ASTLessThan:            return node._testNotation(forOperator: "<")
		case let node as ASTLessOrEqual:         return node._testNotation(forOperator: "<=")
		case let node as ASTAddition:            return node._testNotation(forOperator: "+")
		case let node as ASTSubtraction:         return node._testNotation(forOperator: "-")
		case let node as ASTMultiplication:      return node._testNotation(forOperator: "*")
		case let node as ASTDivision:            return node._testNotation(forOperator: "/")
		case let node as ASTModulo:              return node._testNotation(forOperator: "%")
		case let node as ASTConditionalOperator: return node._testNotation
		case let node as ASTLookup:              return node._testNotation
		case let node as ASTStringLiteral:       return node._value._testNotation
		case let node as ASTNumberLiteral:       return node._value._testNotation
		case let node as ASTBoolLiteral:         return node._value._testNotation
		case          is ASTNullLiteral:         return "NULL"
		case let node as ASTListLiteral:         return node._testNotation
		case let node as ASTDictLiteral:         return node._testNotation
		case let node as ASTIdentifier:          return node._name
		case let node as ASTAccess:              return node._testNotation
		case let node as ASTWhereOperator:       return node._testNotation
		case let node as ASTMapOperator:         return node._testNotation
		case let node as ASTCall:                return node._testNotation
		case let node as ASTSubscript:           return node._testNotation

		default:
			preconditionFailure("testNotation not implemented for \(self.dynamicType)")
		}
	}
}

extension ASTArithmeticNegation {
	private var _testNotation: String {
		return "(-" + _operand.testNotation + ")"
	}
}

extension ASTLogicalNegation {
	private var _testNotation: String {
		return "(!" + _operand.testNotation + ")"
	}
}

extension ASTBinaryOperator {
	private func _testNotation(forOperator operatorString: String) -> String {
		return "(" + _lhs.testNotation + " " + operatorString + " " + _rhs.testNotation + ")"
	}
}

extension ASTConditionalOperator {
	private var _testNotation: String {
		return "(" + _condition.testNotation + " ? " + _positiveExpression.testNotation + " : " + _negativeExpression.testNotation + ")"
	}
}

extension ASTLookup {
	private var _testNotation: String {
		return self._lookup.description
	}
}

extension ASTListLiteral {
	private var _testNotation: String {
		return "[" + _elements.map { $0.testNotation }.joinWithSeparator(", ") + "]"
	}
}

extension ASTDictLiteral {
	private var _testNotation: String {
		if _pairs.isEmpty {
			return "[:]"
		}
		return "[" + _pairs.map { (tuple) -> String in tuple.0.testNotation + ":" + tuple.1.testNotation }.joinWithSeparator(", ") + "]"
	}
}

extension ASTAccess {
	private var _testNotation: String {
		return "(" + _object.testNotation + "." + _name + ")"
	}
}

extension ASTWhereOperator {
	private var _testNotation: String {
		return "(" + _iterableExpression.testNotation + " where " + _identifier + " : " + _predicateExpression.testNotation + ")"
	}
}

extension ASTMapOperator {
	private var _testNotation: String {
		return "(" + _iterableExpression.testNotation + " map " + _identifier + " : " + _transformExpression.testNotation + ")"
	}
}

extension ASTCall {
	private var _testNotation: String {
		return "(" + _callable.testNotation + "(" + _arguments.map { (arg) -> String in arg.testNotation }.joinWithSeparator(", ") + "))"
	}
}

extension ASTSubscript {
	private var _testNotation: String {
		return "(" + _container.testNotation + "->[" + _key.testNotation + "])"
	}
}


// MARK: - Evaluation Tests

extension Value : TestNotation {
	var testNotation: Swift.String {
		switch self {
		case .Null:                       return "NULL"
		case .Bool(let bool):             return bool._testNotation
		case .Number(let number):         return number._testNotation
		case .Date(let timestamp):        return Swift.String(timestamp)
		case .String(let string):         return string.value._testNotation
		case .List(let elements):         return elements._testNotation
		case .Dictionary(let dictionary): return dictionary._testNotation
		case .Callable(let callable):     return "<callable " + callable.name + ">"
		case .Object(let object):         return object.nrx_debugDescription
		}
	}
}

// MARK: - Helper methods to convert Swift types to testNotation

extension Bool {
	private var _testNotation: String {
		return self ? "true" : "false"
	}
}

extension Float64 {
	private var _testNotation: String {
		let integer = lround(self)
		if Float64(integer) == self {
			return String(integer)
		}
		return String(self)
	}
}

extension String {
	private var _testNotation: String {
		guard self.utf8.contains({ $0 == 34 || $0 == 92 }) else {
			// fast path for strings that need no escaping
			return "\"" + self + "\""
		}

		// loop over characters and prefix any that need escaping
		var result = "\""
		for character in self.characters {
			switch character {
			case "\"":
				result += "\\\""
			case "\\":
				result += "\\\\"
			default:
				result += String(character)
			}
		}
		result += "\""
		return result
	}
}


extension SequenceType where Self.Generator.Element == Value {
	private var _testNotation: String {
		return "[" + self.map { $0.testNotation }.joinWithSeparator(", ") + "]"
	}
}

extension SequenceType where Self.Generator.Element == (String, Value) {
	private var _testNotation: String {
		let sortedPairs = Array(self).sort { $0.0 < $1.0 }
		if sortedPairs.isEmpty {
			return "[:]"
		}
		return "[" + sortedPairs.map { (key, value) -> String in key._testNotation + ":" + value.testNotation }.joinWithSeparator(", ") + "]"
	}
}

