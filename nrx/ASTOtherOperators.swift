// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTConditionalOperator: ASTExpression {
	let _condition: ASTExpression
	let _positiveExpression: ASTExpression
	let _negativeExpression: ASTExpression

	required init(condition: ASTExpression, positiveExpression: ASTExpression, negativeExpression: ASTExpression) {
		_condition = condition
		_positiveExpression = positiveExpression
		_negativeExpression = negativeExpression
	}
}


final class ASTLookup: ASTExpression {
	enum Element {
		case Single(String)
		case Multi(String)
	}

	let _elements: [Element]

	init(elements: [Element]) {
		_elements = elements
	}
}

final class ASTIdentifier: ASTExpression {
	let _name: String

	init(name: String) {
		_name = name
	}
}

final class ASTAccess: ASTExpression {
	let _object: ASTExpression
	let _name: String

	init(object: ASTExpression, name: String) {
		_object = object
		_name = name
	}
}

final class ASTWhereOperator: ASTExpression {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _predicateExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, predicateExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_predicateExpression = predicateExpression
	}
}

final class ASTMapOperator: ASTExpression {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _transformExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, transformExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_transformExpression = transformExpression
	}
}

final class ASTCall: ASTExpression {
	let _callable: ASTExpression
	let _arguments: [ASTExpression]

	init(callable: ASTExpression, arguments: [ASTExpression]) {
		_callable = callable
		_arguments = arguments
	}
}

final class ASTSubscript: ASTExpression {
	let _container: ASTExpression
	let _index: ASTExpression

	init(container: ASTExpression, index: ASTExpression) {
		_container = container
		_index = index
	}
}
