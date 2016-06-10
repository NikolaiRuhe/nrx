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

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let condition = try _condition.evaluate(runtime: runtime).boolValue()
		let branch = condition ? _positiveExpression : _negativeExpression
		return try branch.evaluate(runtime: runtime)
	}
}


final class ASTLookup: ASTExpression {
	let _lookup: LookupDescription

	init(elements: [LookupDescription.Element]) {
		_lookup = LookupDescription(elements: elements)
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
	}
}

final class ASTIdentifier: ASTExpression {
	let _name: String

	init(name: String) {
		_name = name
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
	}
}

final class ASTAccess: ASTExpression {
	let _object: ASTExpression
	let _name: String

	init(object: ASTExpression, name: String) {
		_object = object
		_name = name
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
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

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
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

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
	}
}

final class ASTCall: ASTExpression {
	let _callable: ASTExpression
	let _arguments: [ASTExpression]

	init(callable: ASTExpression, arguments: [ASTExpression]) {
		_callable = callable
		_arguments = arguments
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
	}
}

final class ASTSubscript: ASTExpression {
	let _container: ASTExpression
	let _key: ASTExpression

	init(container: ASTExpression, key: ASTExpression) {
		_container = container
		_key = key
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw EvaluationError.Exception(reason: "not yet implemented")
	}
}
