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


extension ASTNode : TestNotation {

	// NOTE: As of Swift 2.2 it's not possible to override declarations in extensions. So we have
	// to resort to this ugly big switch instead of overriding `testNotation` in each subclass.
	var testNotation: String {
		switch self {

		case let node as ASTArithmeticNegation:  return node.testNotation(forOperator: "-")
		case let node as ASTLogicalNegation:     return node.testNotation(forOperator: "!")

		case let node as ASTExcept:              return node.testNotation(forOperator: "except")
		case let node as ASTContains:            return node.testNotation(forOperator: "contains")
		case let node as ASTLogicOr:             return node.testNotation(forOperator: "||")
		case let node as ASTLogicAnd:            return node.testNotation(forOperator: "&&")
		case let node as ASTEqual:               return node.testNotation(forOperator: "==")
		case let node as ASTNotEqual:            return node.testNotation(forOperator: "!=")
		case let node as ASTGreaterThan:         return node.testNotation(forOperator: ">")
		case let node as ASTGreaterOrEqual:      return node.testNotation(forOperator: ">=")
		case let node as ASTLessThan:            return node.testNotation(forOperator: "<")
		case let node as ASTLessOrEqual:         return node.testNotation(forOperator: "<=")
		case let node as ASTAddition:            return node.testNotation(forOperator: "+")
		case let node as ASTSubtraction:         return node.testNotation(forOperator: "-")
		case let node as ASTMultiplication:      return node.testNotation(forOperator: "*")
		case let node as ASTDivision:            return node.testNotation(forOperator: "/")
		case let node as ASTModulo:              return node.testNotation(forOperator: "%")

		case let node as ASTConditionalOperator:
			return "(" + node._condition.testNotation + " ? " + node._positiveExpression.testNotation + " : " + node._negativeExpression.testNotation + ")"

		case let node as ASTLookup:
			return node._elements.map {
				switch $0 {
				case .Single (let name): return "$" + name
				case .Multi (let name):  return "$$" + name
				}
			}.joinWithSeparator("")

		case let node as ASTStringLiteral:
			return "\"" + node._value + "\""
			
		case let node as ASTNumberLiteral:
			return String(node._value)

		case let node as ASTBoolLiteral:
			return (node._value ? "true" : "false")

		case is ASTNullLiteral:
			return "NULL"

		case let node as ASTListLiteral:
			return "[" + node._elements.map { $0.testNotation }.joinWithSeparator(", ") + "]"

		case let node as ASTDictLiteral:
			if node._pairs.isEmpty {
				return "[:]"
			}
			return "[" + node._pairs.map { (tuple) -> String in tuple.0.testNotation + ":" + tuple.1.testNotation }.joinWithSeparator(", ") + "]"

		case let node as ASTIdentifier:
			return node._name

		case let node as ASTAccess:
			return "(" + node._object.testNotation + "." + node._name + ")"

		case let node as ASTWhereOperator:
			return "(" + node._iterableExpression.testNotation + " where " + node._identifier + " : " + node._predicateExpression.testNotation + ")"

		case let node as ASTMapOperator:
			return "(" + node._iterableExpression.testNotation + " map " + node._identifier + " : " + node._transformExpression.testNotation + ")"

		case let node as ASTCall:
			return "(" + node._callable.testNotation + "(" + node._arguments.map { (arg) -> String in arg.testNotation }.joinWithSeparator(", ") + "))"

		case let node as ASTSubscript:
			return "(" + node._container.testNotation + "[" + node._index.testNotation + "])"

		default:
			preconditionFailure("testNotation not implemented for \(self.dynamicType)")
		}
	}
}

extension ASTUnaryOperator {
	private func testNotation(forOperator operatorString: String) -> String {
		return "(" + operatorString + _operand.testNotation + ")"
	}
}

extension ASTBinaryOperator {
	private func testNotation(forOperator operatorString: String) -> String {
		return "(" + _lhs.testNotation + " " + operatorString + " " + _rhs.testNotation + ")"
	}
}



extension Value : TestNotation {
	var testNotation: Swift.String {
		switch self {
		case .Null:                       return "NULL"
		case .Bool(let bool):             return bool ? "true" : "false"
		case .Number(let number):         return Swift.String(number)
		case .Date(let timestamp):        return Swift.String(timestamp)
		case .String(let string):         return stringLiteral(string.value)
		case .List(let list):             return listLiteral(list)
		case .Dictionary(let dictionary): return dictionaryLiteral(dictionary)
		case .Object(let object):         return object.nrx_debugDescription
		}
	}
}

private func stringLiteral(value: String) -> String {
	guard value.utf8.contains(34) else {
		// fast path for strings that need no escaping
		return "\"" + value + "\""
	}

	// loop over characters and prefix any that need escaping
	var result = "\""
	for character in value.characters {
		if character == "\"" {
			result += "\\\""
		} else {
			result += String(character)
		}
	}
	result += "\""
	return result
}

private func listLiteral(value: [Value]) -> String {
	return "[" + value.map { $0.testNotation }.joinWithSeparator(", ") + "]"
}

private func dictionaryLiteral(dictionary: [String: Value]) -> String {
	if dictionary.isEmpty {
		return "[:]"
	}
	let sortedPairs = Array(dictionary).sort { $0.0 < $1.0 }
	return "[" + sortedPairs.map { (key, value) -> String in stringLiteral(key) + ":" + value.testNotation }.joinWithSeparator(", ") + "]"
}
