// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


class ASTNode {
	private init() {}
}

class ASTExpression: ASTNode {}

class ASTLiteral: ASTExpression {}

class ASTUnaryExpression: ASTExpression {
	var _operand: ASTExpression

	init(operand: ASTExpression) {
		_operand = operand
	}
}

class ASTBinaryExpression: ASTExpression {
	var _lhs: ASTExpression
	var _rhs: ASTExpression

	required init(lhs: ASTExpression, rhs: ASTExpression) {
		_lhs = lhs
		_rhs = rhs
	}
}



class ASTNegation: ASTUnaryExpression {}
class ASTLogicalNegation: ASTUnaryExpression {}

class ASTExcept: ASTBinaryExpression {}
class ASTContains: ASTBinaryExpression {}
class ASTLogicOr: ASTBinaryExpression {}
class ASTLogicAnd: ASTBinaryExpression {}
class ASTEqual: ASTBinaryExpression {}
class ASTNotEqual: ASTBinaryExpression {}
class ASTGreaterThan: ASTBinaryExpression {}
class ASTGreaterOrEqual: ASTBinaryExpression {}
class ASTLessThan: ASTBinaryExpression {}
class ASTLessOrEqual: ASTBinaryExpression {}
class ASTAddition: ASTBinaryExpression {}
class ASTSubtraction: ASTBinaryExpression {}
class ASTMultiplication: ASTBinaryExpression {}
class ASTDivision: ASTBinaryExpression {}
class ASTModulo: ASTBinaryExpression {}

class ASTConditionalOperator: ASTExpression {
	var _condition: ASTExpression
	var _positiveExpression: ASTExpression
	var _negativeExpression: ASTExpression

	required init(condition: ASTExpression, positiveExpression: ASTExpression, negativeExpression: ASTExpression) {
		_condition = condition
		_positiveExpression = positiveExpression
		_negativeExpression = negativeExpression
	}
}


class ASTLookup: ASTExpression {

	enum Element {
		case Single(String)
		case Multi(String)
	}

	let _elements: [Element]

	init(elements: [Element]) {
		_elements = elements
	}
}

class ASTStringLiteral: ASTLiteral {
	let _value: String

	init(_ value: String) {
		_value = value
	}
}

class ASTIntLiteral: ASTLiteral {
	let _value: Int64

	init?(fromString: String) {
		guard let value = Int64(fromString) else {
			return nil
		}
		_value = value
	}
}

class ASTFloatLiteral: ASTLiteral {
	let _value: Float64

	init?(fromString: String) {
		guard let value = Float64(fromString) else {
			return nil
		}
		_value = value
	}
}

class ASTBoolLiteral: ASTLiteral {
	let _value: Bool

	init(_ value: Bool) {
		_value = value
	}
}

class ASTNullLiteral: ASTLiteral {
	internal static var null: ASTNullLiteral = ASTNullLiteral()
}

class ASTListLiteral: ASTLiteral {
	let _elements: [ASTExpression]

	init(elements: [ASTExpression]) {
		_elements = elements
	}
}

class ASTDictLiteral: ASTLiteral {
	let _pairs: [(ASTExpression, ASTExpression)]

	init(pairs: [(ASTExpression, ASTExpression)]) {
		_pairs = pairs
	}
}

class ASTIdentifier: ASTExpression {
	let _name: String

	init(name: String) {
		_name = name
	}
}

class ASTAccess: ASTExpression {
	let _object: ASTExpression
	let _name: String

	init(object: ASTExpression, name: String) {
		_object = object
		_name = name
	}
}

class ASTWhereOperator: ASTExpression {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _predicateExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, predicateExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_predicateExpression = predicateExpression
	}
}

class ASTMapOperator: ASTExpression {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _transformExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, transformExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_transformExpression = transformExpression
	}
}

class ASTCall: ASTExpression {
	let _callable: ASTExpression
	let _arguments: [ASTExpression]

	init(callable: ASTExpression, arguments: [ASTExpression]) {
		_callable = callable
		_arguments = arguments
	}
}

class ASTSubscript: ASTExpression {
	let _container: ASTExpression
	let _index: ASTExpression

	init(container: ASTExpression, index: ASTExpression) {
		_container = container
		_index = index
	}
}
